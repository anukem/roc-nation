app "operational-transforms"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.3/5SXwdW7rH8QAOnD71IkHcFxCmBEPtFSLAIkclPEgjHQ.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf

printState = \state ->
  when state is
    State s c -> Stdout.line s
    Invalid -> Stdout.line "invalid"


sliceHelper = \{middle} -> {middle: List.dropIf middle Str.isEmpty }

sliceProcessor = \s, start, end ->
  if (start < 0) || (end > Str.countGraphemes s)
  then {step: 0, middle: [""], leftover: [""]}
  else List.walk (Str.graphemes s) {step: 0, middle: [""], leftover: [""]}
    \state, elem ->
      if start <= state.step && state.step < end
      then {step: state.step + 1, middle: List.append state.middle elem, leftover: state.leftover}
      else {step: state.step + 1, middle: state.middle, leftover: List.append state.leftover elem}

slice = \s, start, end -> sliceProcessor s start end |> sliceHelper

expect
  first = (slice "dogs" 0 1).middle
  first == ["d"]


main = Stdout.line "its out"
