defmodule EVM.Builtin do
  @moduledoc """
  Implements the built-in functions as defined in Appendix E
  of the Yellow Paper. These are contract functions that
  natively exist in Ethereum.

  TODO: Implement and add doc tests.
  """
  @rip160 600 + 120

  @spec run_ecrec(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_ecrec(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}

  @spec run_sha256(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_sha256(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}

  @doc """
  Runs RIPEMD160 hashing

  ## Examples

      iex> EVM.Builtin.run_rip160(3000,  %EVM.ExecEnv{data: <<1, 2, 3>>})
      {2280, %EVM.SubState{}, %EVM.ExecEnv{data: <<1, 2, 3>>}, <<121, 249, 1, 218,
        38, 9, 240, 32, 173, 173, 191, 46, 95, 104, 161, 108, 140, 63, 125, 87>>}
  """
  @spec run_rip160(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_rip160(gas, exec_env = %EVM.ExecEnv{data: data}) do
    used_gas = @rip160 * MathHelper.bits_to_words(byte_size(data))
    if(used_gas < gas) do
      remaining_gas = gas - used_gas
      result = :crypto.hash(:ripemd160, data)
      {remaining_gas, %EVM.SubState{}, exec_env, result}
    else
      {gas, %EVM.SubState{}, exec_env, <<>>}
   end
  end

  @spec run_id(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_id(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}
end
