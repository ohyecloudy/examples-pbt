defmodule PbtTest do
  use ExUnit.Case
  use PropCheck
  use PropCheck.StateM

  property "stateful property" do
    forall cmds <- commands(__MODULE__) do
      ActualSystem.start_link()
      {history, state, result} = run_commands(__MODULE__, cmds)
      ActualSystem.stop()

      (result == :ok)
      |> aggregate(command_names(cmds))
      |> when_fail(
        IO.puts("""
        History: #{inspect(history)}
        State: #{inspect(state)}
        Result: #{inspect(result)}
        """)
      )
    end
  end

  # initial model value at system start. should be deterministic.
  def initial_state() do
    %{}
  end

  # List of possible commands to run against the system
  def command(_state) do
    oneof([
      {:call, ActualSystem, :some_call, [term(), term()]}
    ])
  end

  # determines whether a command should be valid under the current state
  def precondition(_state, {:call, _mod, _fun, _args}) do
    true
  end

  # given that state prior to the call `{:call, mod, fun, args}`,
  # determine whether the result (res) coming from the actual system
  # makes sense according to the model
  def postcondition(_state, {:call, _mod, _fun, _args}, _res) do
    true
  end

  # assuming the postcondition for a call was true, update the model
  # accordingly for the test to proceed
  def next_state(state, _res, {:call, _mod, _fun, _args}) do
    newstate = state
    newstate
  end
end
