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

  func calculateTotalPercentage() : Float {
    var total : Float = 0;
    for (person in people.vals()) {
      total += person.percentage;
    };
    total
  };

  public func addPerson(name: Text) : async Result.Result<Nat, Text> {
    let id = nextPersonId;
    let newPerson: Person = {
      id = id;
      name = name;
      percentage = 0.0;
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

  public func updatePercentages(updates: [(Nat, Float)]) : async Result.Result<(), Text> {
    var newTotal : Float = 0;
    for ((id, percentage) in updates.vals()) {
      switch (people.get(id)) {
        case null { return #err("Person not found") };
        case (?person) {
          newTotal += percentage;
        };
      };
    };

    if (newTotal > 100) {
      return #err("Total percentage cannot exceed 100%");
    };

    for ((id, percentage) in updates.vals()) {
      switch (people.get(id)) {
        case null { /* Already checked, should not happen */ };
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
        };
      };
    };

    #ok(())
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

  public func resetBillAmount() : async () {
    billAmount := 0;
    for ((id, person) in people.entries()) {
      let updatedPerson = {
        id = person.id;
        name = person.name;
        percentage = person.percentage;
        amount = null;
      };
      people.put(id, updatedPerson);
    };
  };

  public func resetPercentages() : async () {
    for ((id, person) in people.entries()) {
      let updatedPerson = {
        id = person.id;
        name = person.name;
        percentage = 0.0;
        amount = null;
      };
      people.put(id, updatedPerson);
    };
  };

  public query func getBillSplit() : async BillSplitInfo {
    let peopleArray = Iter.toArray(people.vals());
    let totalPercentage = calculateTotalPercentage();
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
