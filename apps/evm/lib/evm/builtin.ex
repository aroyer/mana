defmodule EVM.Builtin do
  @moduledoc """
  Implements the built-in functions as defined in Appendix E
  of the Yellow Paper. These are contract functions that
  natively exist in Ethereum.

  TODO: Implement and add doc tests.
  """

  @doc """
  A precompiled contract that recovers a public key from a signed hash
  (Elliptic curve digital signature algorithm public key recovery function)

  ## Examples

      iex> private_key = ExthCrypto.Test.private_key(:key_a)
      iex> public_key = ExthCrypto.Signature.get_public_key(private_key)
      iex> message = EVM.Helpers.left_pad_bytes("hello")
      iex> {signature, _r, _s, v} = ExthCrypto.Signature.sign_digest(message, private_key)
      iex> data = message <>  EVM.Helpers.left_pad_bytes(:binary.encode_unsigned(v)) <> EVM.Helpers.left_pad_bytes(signature)
      iex> ecrec = EVM.Builtin.run_ecrec(4000,  %EVM.ExecEnv{data: data})
      iex> {_, _, _, result} = ecrec
      iex> result == public_key
      true
  """

  @spec run_ecrec(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_ecrec(gas, exec_env) do
    used_gas = 3000

    if(used_gas < gas) do
      input = exec_env.data
      <<h::binary-size(32), v::binary-size(32), r::binary-size(32), s::bitstring>> = input
      signature = r <> s
      result = ExthCrypto.Signature.recover(h, signature, :binary.decode_unsigned(v))
      remaining_gas = gas - used_gas
      {remaining_gas, %EVM.SubState{}, exec_env, result}
    else
      {gas, %EVM.SubState{}, exec_env, <<>>}
    end
  end

  @spec run_sha256(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_sha256(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}

  @spec run_rip160(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_rip160(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}

  @spec run_id(EVM.Gas.t(), EVM.ExecEnv.t()) ::
          {EVM.Gas.t(), EVM.SubState.t(), EVM.ExecEnv.t(), EVM.VM.output()}
  def run_id(gas, exec_env), do: {gas, %EVM.SubState{}, exec_env, <<>>}
end
