defmodule MonoBot.BotWorkerTest do
  use ExUnit.Case, async: true

  alias MonoBot.BotWorker

  @update %Nadia.Model.Update{
    callback_query: nil,
    chosen_inline_result: nil,
    edited_message: nil,
    inline_query: nil,
    message: %Nadia.Model.Message{
      audio: nil,
      caption: nil,
      channel_chat_created: nil,
      chat: %Nadia.Model.Chat{
        first_name: "Nadia",
        id: 123,
        last_name: "TheBot",
        title: nil,
        type: "private",
        username: "nadia_the_bot"
      },
      contact: nil,
      date: 1_471_208_260,
      delete_chat_photo: nil,
      document: nil,
      edit_date: nil,
      entities: nil,
      forward_date: nil,
      forward_from: nil,
      forward_from_chat: nil,
      from: %Nadia.Model.User{
        first_name: "Nadia",
        id: 123,
        last_name: "TheBot",
        username: "nadia_the_bot"
      },
      group_chat_created: nil,
      left_chat_member: nil,
      location: nil,
      message_id: 543,
      migrate_from_chat_id: nil,
      migrate_to_chat_id: nil,
      new_chat_member: nil,
      new_chat_photo: [],
      new_chat_title: nil,
      photo: [],
      pinned_message: nil,
      reply_to_message: nil,
      sticker: nil,
      supergroup_chat_created: nil,
      text: "rew",
      venue: nil,
      video: nil,
      voice: nil
    },
    update_id: 98765
  }

  describe "init/1" do
    test "worker inits and set its state" do
      args = %{}

      assert BotWorker.init(args) == {
               :ok,
               %{offset: 0, api_key: nil}
             }
    end
  end

  describe "handle_info/2 messages" do
    test "do noop if no messafes" do
      assert BotWorker.get_message(nil, %{}) == :noop
    end
  end
end
