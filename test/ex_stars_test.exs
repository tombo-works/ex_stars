defmodule ExSTARSTest do
  use ExUnit.Case

  setup do
    :ok = Application.stop(:ex_stars)
    :ok = Application.ensure_started(:ex_stars)

    on_exit(fn ->
      :ok = Application.stop(:ex_stars)
      :ok = Application.ensure_started(:ex_stars)
    end)

    :ok
  end

  test "start_client/2" do
    assert ExSTARS.start_client({127, 0, 0, 1}, 6057) == :ok
    assert ExSTARS.start_client({127, 0, 0, 1}, 6057) == {:error, :already_started}
  end

  test "start_client/4" do
    assert ExSTARS.start_client("term1", "stars", {127, 0, 0, 1}, 6057) == :ok

    assert ExSTARS.start_client("term1", "stars", {127, 0, 0, 1}, 6057) ==
             {:error, :already_started}
  end

  test "send/1" do
    :ok = ExSTARS.start_client({127, 0, 0, 1}, 6057)
    assert ExSTARS.send("term1 stars") == {:error, :send_failed}
  end

  test "send/2" do
    :ok = ExSTARS.start_client("term1", "stars", {127, 0, 0, 1}, 6057)
    assert ExSTARS.send("term1", "System getversion") == {:error, :send_failed}
  end
end
