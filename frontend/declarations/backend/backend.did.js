export const idlFactory = ({ IDL }) => {
  const Result_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const Person = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'amount' : IDL.Opt(IDL.Float64),
    'percentage' : IDL.Float64,
  });
  const BillSplitInfo = IDL.Record({
    'people' : IDL.Vec(Person),
    'totalAmount' : IDL.Float64,
    'totalPercentage' : IDL.Float64,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'addPerson' : IDL.Func([IDL.Text], [Result_1], []),
    'calculateAmounts' : IDL.Func([IDL.Float64], [IDL.Vec(Person)], ['query']),
    'getBillSplit' : IDL.Func([], [BillSplitInfo], ['query']),
    'removePerson' : IDL.Func([IDL.Nat], [Result], []),
    'resetBillAmount' : IDL.Func([], [], []),
    'resetPercentages' : IDL.Func([], [], []),
    'setBillAmount' : IDL.Func([IDL.Float64], [], []),
    'updatePercentages' : IDL.Func(
        [IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Float64))],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
