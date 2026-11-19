---------------------------- MODULE NativeTrace ----------------------------
EXTENDS Naturals, Integers, Sequences, FiniteSets, Bags, TLC, TLCExt, Json,
        Randomization

CONSTANTS Procs, N

VARIABLES pc, count, log

vars == <<pc, count, log>>

Rec == [name |-> "a", val |-> 1]

ASSUME
  /\ 2 + 3 * 4 - 1 = 13
  /\ (-7) \div 2 = -4 /\ (-7) % 2 = 1 /\ 2^10 = 1024 /\ -3 < 3
  /\ Cardinality(1..10) = 10 /\ IsFiniteSet({1, 2})
  /\ Len(Append(<<1, 2>>, 3)) = 3 /\ Head(<<1, 2>>) = 1 /\ Tail(<<1, 2>>) = <<2>>
  /\ SubSeq(<<1, 2, 3, 4>>, 2, 3) = <<2, 3>>
  /\ SelectSeq(<<1, 2, 3, 4>>, LAMBDA e : e % 2 = 0) = <<2, 4>>
  /\ <<1>> \o <<2>> = <<1, 2>> /\ "ab" \o "c" = "abc" /\ <<1, 1>> \in Seq({1})
  /\ IsABag(EmptyBag) /\ BagCardinality(SetToBag({1, 2})) = 2
  /\ BagToSet(SetToBag({1})) = {1} /\ CopiesIn(1, SetToBag({1})) = 1
  /\ BagIn(1, SetToBag({1})) /\ SetToBag({1}) (+) SetToBag({1}) = (1 :> 2)
  /\ SortSeq(<<3, 1, 2>>, <) = <<1, 2, 3>>
  /\ Cardinality(Permutations({1, 2, 3})) = 6
  /\ ToString(42) = "42"
  /\ RandomElement({1, 2}) \in {1, 2}
  /\ Cardinality(RandomSubset(2, 1..5)) = 2
  /\ RandomSetOfSubsets(3, 2, 1..5) \subseteq SUBSET (1..5)
  /\ JsonSerialize("NativeTrace.json", <<Rec>>)
  /\ JsonDeserialize("NativeTrace.json") = <<Rec>>
  /\ ndJsonSerialize("NativeTrace.ndjson", <<Rec>>)
  /\ ndJsonDeserialize("NativeTrace.ndjson") = <<Rec>>
  /\ ToJson(<<1, 2>>) = "[1,2]"
  /\ AssertEq(TLCEval(1 + 1), 2)
  /\ TLCModelValue("mv") = TLCModelValue("mv")
  /\ TLCNoOp(1) = 1
  /\ JavaTime > 0
  /\ PrintT("native-image trace")

Init ==
  /\ pc = [p \in Procs |-> "idle"]
  /\ count = 0
  /\ log = <<>>

Start(p) ==
  /\ pc[p] = "idle"
  /\ count < N
  /\ pc' = [pc EXCEPT ![p] = "busy"]
  /\ count' = count + 1
  /\ log' = Append(log, p)

Finish(p) ==
  /\ pc[p] = "busy"
  /\ pc' = [pc EXCEPT ![p] = "idle"]
  /\ UNCHANGED <<count, log>>

Reset ==
  /\ count = N
  /\ \A p \in Procs : pc[p] = "idle"
  /\ count' = 0
  /\ log' = <<>>
  /\ UNCHANGED pc

Next == (\E p \in Procs : Start(p) \/ Finish(p)) \/ Reset

Spec == Init /\ [][Next]_vars /\ WF_vars(Next)

DeadlockNext == \E p \in Procs : Start(p) \/ Finish(p)
DeadlockSpec == Init /\ [][DeadlockNext]_vars

UnfairSpec == Init /\ [][Next]_vars

TypeOK ==
  /\ pc \in [Procs -> {"idle", "busy"}]
  /\ count \in 0..N
  /\ log \in Seq(Procs)

Inv == Len(log) = count

BadInv == count < 2

Liveness == []<>(count = 0)

ProcSym == Permutations(Procs)

View == <<pc, count>>

Alias == [pc |-> pc, count |-> count, len |-> Len(log), level |-> TLCGet("level")]

StateConstraint == count <= N

ActionConstraint == count' >= count \/ count' = 0

PostCondition == TLCGet("stats").generated > 0

AllBusy == \A p \in Procs : pc[p] = "busy"

ResetStep == count > 0 /\ count' = 0
=============================================================================
