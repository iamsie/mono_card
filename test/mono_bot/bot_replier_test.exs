defmodule MonoBot.ReplierTest do
  use ExUnit.Case, async: true

  alias MonoBot.Replier

  describe "answer the message/2" do
    test "user send the request to update API MONO KEY" do
      Replier.answer_the_messages(197_893_092, "Update API_MONO_KEY") ==
        {:ok, %Nadia.Model.Message{text: "Send me a new API_MONO_KEY"}}
    end

    test "any row" do
      Replier.answer_the_messages(197_893_092, "Update API_MONO_KEY") ==
        {:ok, %Nadia.Model.Message{text: "What do you want to do?"}}
    end
  end
end
