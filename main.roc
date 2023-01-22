app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.3/5SXwdW7rH8QAOnD71IkHcFxCmBEPtFSLAIkclPEgjHQ.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf


slice = \s, start, end ->
  if (start < 0) || (end > Str.countGraphemes s)
  then {step: 0, result: [""], leftover: [""]}
  else List.walk (Str.graphemes s) {step: 0, result: [""], leftover: [""]}
    \state, elem ->
      if start <= state.step && state.step < end
      then {step: state.step + 1, result: List.append state.result elem, leftover: state.leftover}
      else {step: state.step + 1, result: state.result, leftover: List.append state.leftover elem}

pluralize = \s -> if s > 1 then Bool.true else Bool.false

something = "dogs"

main =
     slice "dogs" 1 (Str.countGraphemes something) |> .result |> Str.joinWith "" |> Stdout.line

