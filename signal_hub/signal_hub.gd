extends Node

#region Pplayer1 and Player2
signal blocking_anim_done

#endregion

#region UI related
signal set_ini_a_state(player_action_state)
signal set_ini_m_state(player_move_state)

signal update_p_health(p_health)
signal update_p_a_state(player_action_state)
signal update_p_m_state(player_move_state)
signal update_p_attack(player_attack)
signal update_p_rage(player_rage)
signal update_p_r_duration(rage_duration)
signal update_p_r_cooling(rage_cooling)

#endregion
