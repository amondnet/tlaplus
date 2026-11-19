------------------------- MODULE NativeTracePCalC --------------------------
EXTENDS Naturals, TLC

(* --algorithm NativeTracePCalC {
  variables i = 0, acc = 0;
  {
    while (i < 5) {
      if (i % 2 = 0) { acc := acc + i } else { skip };
      i := i + 1
    };
    assert acc = 6
  }
} *)
=============================================================================
