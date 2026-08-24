extends Node

#Add game start, game tutorial and stuff 


#region Player1 and Player2
signal blocking_anim_done

signal player_died
#endregion

#region Enemy Boss

signal is_needed_flip

#endregion -- Enemy Boss

#region Stage/Level Related

signal stage_restart
signal back_to_previous_stage
signal pre_boss_fight_dialogue
signal pre_fight_dialogue_done

signal ready_for_second_phase
signal mid_fight_dialogue_done


#endregion  -- Stage/Level Related

#region UI related
signal set_ini_a_state(player_action_state)
signal set_ini_m_state(player_move_state)

signal update_p_stats(v_name: String, value: int)
signal transition_done

#endregion

#region Michael Related

signal michael_blessing_get
signal revival_complete
signal show_michael_tutorial

#endregion Michael Related

#region Platforms

signal is_in_flatform
signal not_in_flatform

#endregion -- Flatforms
