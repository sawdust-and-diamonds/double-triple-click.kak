###############################################################################
#                                 Options                                     #
###############################################################################

## Customizable user options

# Option: doubleclick_wait
# Maximum time, in seconds, between clicks that will register a double click.
declare-option str doubleclick_wait 0.3

# Option: enable_default_doubletripleclick_normal
# Enables the default hook behaviour for this addon:
# Double- and triple- clicks will select words and paragraphs respectively
declare-option bool enable_click-to-select_normal true

# Option: enable_clicks_to_select_insert
# Enables the same behaviour for Insert mode.
declare-option bool enable_click-to-select_insert true

# Alternative command options:
# If you have the defaults set above, these become available.
# Setting any of one of these strings will change the usual behaviour
# See the examples below.
declare-option str doubleclick_alternative_normal
declare-option str doubleclick_alternative_insert
declare-option str tripleclick_alternative_normal
declare-option str tripleclick_alternative_insert

## Hidden options, used by the system

# Option: snd_just_clicked
# What's the status of our current chain of clicks?
# Value 0: No clicks made in timescale set by %opt{doubleclick_wait}
# Value 1: Single click
# Value 2: Double click
# Value 3: Triple click. Loops back to 1 over this point.
declare-option -hidden int snd_just_clicked 0

# Option: snd_click_count
# How many clicks have been made in total?
# (The maximum time between clicks is set by doubleclick_wait)
declare-option -hidden int snd_click_count 0

###############################################################################
#                              Functionality                                  #
###############################################################################

eval %sh{
    $kak_opt_init_done && exit
    # exit
    echo "hook global NormalKey '<mouse:press:left:.*>' snd-wait-after-click"
    echo "hook global InsertKey '<mouse:press:left:.*>' snd-wait-after-click"
    echo "hook global NormalKey '<mouse:press:left:.*>' snd-mouse-select2"
    echo "hook global InsertKey '<mouse:press:left:.*>' snd-mouse-select2"
    echo "hook global NormalKey '<mouse:release:left:.*>' snd-mouse-select"
    echo "hook global InsertKey '<mouse:release:left:.*>' snd-mouse-select"
}

define-command snd-mouse-select2 -override -hidden %{
    eval %sh{
        echo "set-option global snd_just_clicked $((kak_opt_snd_just_clicked + 1))"
        if [ "$kak_opt_snd_just_clicked" -eq 3 ]; then
            echo "set-option global snd_just_clicked 1" 
        fi
    } 
    snd-mouse-select
}

define-command snd-mouse-select -override -hidden %{
    eval %sh{
        if   [ "$kak_opt_snd_just_clicked" -eq 2 ]; then
            echo "try %{exec '<a-i>w'} catch %{nop}" 
        elif [ "$kak_opt_snd_just_clicked" -eq 3 ]; then
            echo "try %{exec '<a-i>p'} catch %{nop}" 
        fi
    }
}

# define-command snd-exec-with-delay -params 1 -override -hidden %{
#     eval %sh{
#         sleep 0.01
#         echo "exec $1" | kak -p "$kak_session"
#     }
# }

define-command snd-wait-after-click -override -hidden %{
    eval %sh{(
        n=$(( kak_opt_snd_click_count + 1 ))
        echo "set-option global snd_click_count $n" | kak -p "$kak_session"
sleep $kak_opt_doubleclick_wait
        # echoception
        echo "eval %sh{
            if [ \$kak_opt_snd_click_count -eq $n ]; then
                echo 'set-option global snd_just_clicked 0'
                echo 'set-option global snd_click_count 0'
            fi
        }" | kak -p "$kak_session" ) >/dev/null 2>&1 </dev/null &
    }
}
