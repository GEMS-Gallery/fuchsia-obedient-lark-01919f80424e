import Hash "mo:base/Hash";
import Text "mo:base/Text";

import Float "mo:base/Float";
import Array "mo:base/Array";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

actor {
  type Person = {
    id: Nat;
    name: Text;
    percentage: Float;
    amount: ?Float;
  };

  type BillSplitInfo = {
    totalAmount: Float;
    people: [Person];
    totalPercentage: Float;
  };

  stable var nextPersonId: Nat = 0;
  stable var peopleEntries: [(Nat, Person)] = [];
  var people = HashMap.fromIter<Nat, Person>(peopleEntries.vals(), 0, Nat.equal, Nat.hash);
  var billAmount: Float = 0;

  public func addPerson(name: Text) : async Result.Result<Nat, Text> {
    let id = nextPersonId;
    let newPerson: Person = {
      id = id;
      name = name;
      percentage = 0;
      amount = null;
    };
    people.put(id, newPerson);
    nextPersonId += 1;
    #ok(id)
  };

  public func removePerson(id: Nat) : async Result.Result<(), Text> {
    switch (people.remove(id)) {
      case null { #err("Person not found") };
      case (?_) { #ok(()) };
    }
  };

  public func updatePercentage(id: Nat, percentage: Float) : async Result.Result<(), Text> {
    switch (people.get(id)) {
      case null { #err("Person not found") };
      case (?person) {
        let updatedPerson = {
          id = person.id;
          name = person.name;
          percentage = percentage;
          amount = if (billAmount > 0) {
            ?(billAmount * percentage / 100)
          } else {
            null
          };
        };
        people.put(id, updatedPerson);
        #ok(())
      };
    }
  };

  public query func calculateAmounts(newBillAmount: Float) : async [Person] {
    Iter.toArray(Iter.map(people.vals(), func (person: Person) : Person {
      {
        id = person.id;
        name = person.name;
        percentage = person.percentage;
        amount = if (newBillAmount > 0) {
          ?(newBillAmount * person.percentage / 100)
        } else {
          null
        };
      }
    }))
  };

  public func setBillAmount(amount: Float) : async () {
    billAmount := amount;
    for ((id, person) in people.entries()) {
      let updatedPerson = {
        id = person.id;
        name = person.name;
        percentage = person.percentage;
        amount = if (amount > 0) {
          ?(amount * person.percentage / 100)
        } else {
          null
        };
      };
      people.put(id, updatedPerson);
    };
  };

  public query func getBillSplit() : async BillSplitInfo {
    let peopleArray = Iter.toArray(people.vals());
    let totalPercentage = Array.foldLeft<Person, Float>(peopleArray, 0, func(acc, p) { acc + p.percentage });
    {
      totalAmount = billAmount;
      people = peopleArray;
      totalPercentage = totalPercentage;
    }
  };

  system func preupgrade() {
    peopleEntries := Iter.toArray(people.entries());
  };

  system func postupgrade() {
    people := HashMap.fromIter<Nat, Person>(peopleEntries.vals(), 0, Nat.equal, Nat.hash);
  };
}
