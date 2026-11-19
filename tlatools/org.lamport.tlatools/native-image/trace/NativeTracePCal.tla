-------------------------- MODULE NativeTracePCal --------------------------
EXTENDS Naturals, Sequences, TLC

(* --algorithm NativeTracePCal
variables queue = <<>>, total = 0;

define
  QueueBounded == Len(queue) <= 2
end define;

macro Push(v) begin
  queue := Append(queue, v);
end macro;

procedure Add(n) begin
  AddStep:
    total := total + n;
    return;
end procedure;

process Producer \in {1, 2}
variables sent = 0;
begin
  Produce:
    while sent < 2 do
      await Len(queue) < 2;
      either Push(self) or Push(self + 10) end either;
      sent := sent + 1;
    end while;
end process;

process Consumer = 0
variables got = 0;
begin
  Consume:
    while got < 4 do
      await queue # <<>>;
      with v = Head(queue) do
        queue := Tail(queue);
        call Add(v);
      end with;
      Count:
        got := got + 1;
    end while;
end process;
end algorithm; *)
=============================================================================
