extends Node

#Add game start, game tutorial and stuff 


#region Player1 and Player2
signal blocking_anim_done

signal player_died
#endregion

#region Stage/Level Related

signal stage_restart
signal back_to_previous_stage

#endregion  -- Stage/Level Related

#region UI related
signal set_ini_a_state(player_action_state)
signal set_ini_m_state(player_move_state)

signal update_p_stats(v_name: String, value: int)
signal transition_done

#endregion
