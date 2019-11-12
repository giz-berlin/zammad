class Sessions::Event::ChatAgentState < Sessions::Event::ChatBase

  def run
    return super if super

    # check if user has permissions
    return if !permission_check('chat.agent', 'chat')

    chat_user = User.lookup(id: @session['id'])

    Chat::Agent.state(@session['id'], @payload['data']['active'])

    chat_ids = Chat.agent_active_chat_ids(chat_user)

    # broadcast new state to agents
    Chat.broadcast_agent_state_update(chat_ids, @session['id'])

    {
      event: 'chat_agent_state',
      data:  {
        state:  'ok',
        active: @payload['data']['active'],
      },
    }
  end

end
