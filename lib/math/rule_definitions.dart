const String joiningRule = 'If x and y are theorems, then <x∧y> is a theorem';

const String separationRule = 'If <x∧y> is a theorum, then both x and y are theorems. ';

const String doubleTildeRule = "The string '~~' can be deleted from any theorem. It can also be inserted into any theorem, provided that the resulting string is itself well formed.";

const String fantasyRule = 'If y can be derived when x is assumed to be a theorem, then <x⊃y> is a theorem.';

const String carryOverRule = 'Inside a fantasy, any theorem from the "reality" one level higher can be brought in and used.';

const String detachmentRule = 'If x and <x⊃y> are both theorems, then y is a theorem.';

const String contrapositiveRule = '<x⊃y and <~y⊃~x> are interchangeable.';

const String deMorgansRule = '<~x∧~y> and ~<x∨y> are interchangeable.';

const String switcherooRule = '<x∨y> and <~x⊃y> are interchangeable.';


