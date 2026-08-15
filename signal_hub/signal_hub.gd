extends Node

#Add game start, game tutorial and stuff 


#region Pplayer1 and Player2
signal blocking_anim_done

#endregion

#region UI related
signal set_ini_a_state(player_action_state)
signal set_ini_m_state(player_move_state)

signal update_p_stats(v_name: String, value: int)
signal transition_to_prologue
signal transition_to_tutorial
signal transition_to_grassland
signal transition_done

#endregion
