import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface BillSplitInfo {
  'people' : Array<Person>,
  'totalAmount' : number,
  'totalPercentage' : number,
}
export interface Person {
  'id' : bigint,
  'name' : string,
  'amount' : [] | [number],
  'percentage' : number,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : bigint } |
  { 'err' : string };
export interface _SERVICE {
  'addPerson' : ActorMethod<[string], Result_1>,
  'getBillSplit' : ActorMethod<[], BillSplitInfo>,
  'removePerson' : ActorMethod<[bigint], Result>,
  'setBillAmount' : ActorMethod<[number], undefined>,
  'updatePercentage' : ActorMethod<[bigint, number], Result>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
