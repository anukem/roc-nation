app "operational-transforms"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.3/5SXwdW7rH8QAOnD71IkHcFxCmBEPtFSLAIkclPEgjHQ.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf

printState = \state ->
  when state is
    State s c -> Stdout.line s
    Invalid -> Stdout.line "invalid"

filterOutEmpty = \lst -> List.dropIf lst Str.isEmpty

sliceHelper = \{middle, ending, beginning} -> {
  middle: filterOutEmpty middle,
  ending: filterOutEmpty ending,
  beginning: filterOutEmpty beginning
}

sliceProcessor = \s, start, end ->
  if (start < 0) || (end > Str.countGraphemes s)
  then {step: 0, beginning: [""], middle: [""], ending: [""]}
  else List.walk (Str.graphemes s) {step: 0, beginning: [""], middle: [""], ending: [""]}
    \state, elem ->
      if state.step < start then {
        beginning: List.append state.beginning elem,
        step: state.step + 1,
        middle: state.middle,
        ending: state.ending
      } else if start <= state.step && state.step < end then {
        beginning: state.beginning,
        step: state.step + 1,
        middle: List.append state.middle elem,
        ending: state.ending
      } else {
        beginning: state.beginning,
        step: state.step,
        middle: state.middle,
        ending: List.append state.ending elem
      }
slice = \s, start, end -> sliceProcessor s start end |> sliceHelper


applyOp = \op, state ->
  when state is
    Invalid -> Invalid
    State initial position ->
      when op is
        Insert s ->
          {beginning, ending} = slice initial position position
          State (Str.joinWith (List.join [beginning, [s], ending]) "") (position + (Str.countGraphemes s))
        Delete c ->
          {beginning, ending} = slice initial position position
          filteredEnding = List.takeLast ending (Str.countGraphemes (Str.joinWith ending "") - c)
          State (Str.joinWith (List.join [beginning, filteredEnding]) "") position
        Skip c ->
          State initial (position + c)

getPosition = \position ->
  when position is
    Invalid -> 0
    State _s c -> c

getState = \state ->
  when state is
    Invalid -> ""
    State s _c -> s



expect
  first = (slice "dogs" 0 1).beginning
  first == []
expect
  second = (slice "dogs" 0 1).middle
  second == ["d"]
expect
  third = (slice "dogs" 0 1).ending
  third == ["o", "g", "s"]
expect
  newState = applyOp (Insert "hello") (State "ezeugo" 2)
  (getState newState) == "ezhelloeugo"
expect
  newState = applyOp (Delete 2) (State "ezeugo" 2)
  (getState newState) == "ezgo"
expect
  newState = applyOp (Skip 2) (State "ezeugo" 2)
  (getPosition newState) == 4
expect
  beginning = (slice "dogs" 1 3).beginning
  beginning == ["d"]
expect
  middle = (slice "dogs" 1 3).middle
  middle == ["o", "g"]
expect
  end = (slice "dogs" 1 3).ending
  end == ["s"]
expect
  left = (slice "dogs" 1 1).beginning
  right = (slice "dogs" 1 1).ending
  (left == ["d"]) &&
  (right == ["o", "g", "s"])

main = Stdout.line "its out"
