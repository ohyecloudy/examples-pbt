defmodule CheckoutNegativeTest do
  use ExUnit.Case
  use PropCheck

  property "negative testing for expected results" do
    forall {items, prices, specials} <- lax_lists() do
      try do
        is_integer(Checkout.total(items, prices, specials))
      rescue
        e in [RuntimeError] ->
          e.message == "invalid list of prices" ||
            e.message == "invalid list of specials" ||
            String.starts_with?(e.message, "unknown item:")

        _ ->
          false
      end
    end
  end

  property "expected results", [:verbose] do
    forall {items, prices, specials} <- lax_lists() do
      collect(
        try do
          is_integer(Checkout.total(items, prices, specials))
        rescue
          e in [RuntimeError] ->
            e.message == "invalid list of prices" ||
              e.message == "invalid list of specials" ||
              String.starts_with?(e.message, "unknown item:")

          _ ->
            false
        end,
        item_list_type(items, prices)
      )
    end
  end

  defp item_list_type(items, prices) do
    if Enum.all?(items, &has_price(&1, prices)) do
      :valid
    else
      :prices_missing
    end
  end

  defp has_price(item, price_list) do
    case List.keyfind(price_list, item, 0) do
      nil -> false
      {_, _price} -> true
    end
  end

  defp lax_lists() do
    known_items = ["A", "B", "C"]
    maybe_known_item_gen = elements(known_items ++ [utf8()])

    {
      list(maybe_known_item_gen),
      list({maybe_known_item_gen, integer()}),
      list({maybe_known_item_gen, integer(), integer()})
    }
  end
end
