###############################################################################
#                                 Options                                     #
###############################################################################

## Customizable user options

# Option: doubleclick_wait
# Maximum time, in seconds, between clicks that will register a double click.
declare-option str doubleclick_wait 0.3

## Hooks
# These hooks determine the behaviour of your double- and triple- clicks.
# The default behaviour should be quite inoffensive, so I have left them on by default.
# You may re-define them in your kakrc (or here) to do whatever you want them to do.

# With a little bit of effort, you can probably also add new click behaviours for other
# modes, but you might have to use the RawKey hook to do it.

# We use try/catch here because we may often click on blank spaces.

hook global User NormalDoubleClick %{
    # Select word
    try %{exec '<a-i>w'} catch %{nop}
}
hook global User NormalTripleClick %{
    # Select line.
	try %{exec 'x'} catch %{nop} 
}
hook global User InsertDoubleClick %{
    # Select word (from insert mode)
    try %{exec '<a-;><a-i>w'} catch %{nop}
}
hook global User InsertTripleClick %{
    # Select word (from insert mode)
    try %{exec '<a-;>x'} catch %{nop}
}

## Hidden options, used by the system

# Option: just_clicked
# What's the status of our current chain of clicks?
# Value 0: No clicks made in timescale set by %opt{doubleclick_wait}
# Value 1: Single click
# Value 2: Double click
# Value 3: Triple click. Loops back to 1 over this point.
declare-option -hidden int just_clicked 0

# Option: cur_click_count
# How many clicks have been made in total?
# (The maximum time between clicks is set by doubleclick_wait)
declare-option -hidden int cur_click_count 0

###############################################################################
#                              Functionality                                  #
###############################################################################

# Here we hook into the basic mouse-click actions:
hook global NormalKey '<mouse:press:left:.*>' 'wait_for_next_click'
hook global InsertKey '<mouse:press:left:.*>' 'wait_for_next_click'
hook global NormalKey '<mouse:press:left:.*>' 'inc_click_count normal'
hook global InsertKey '<mouse:press:left:.*>' 'inc_click_count insert'
hook global NormalKey '<mouse:release:left:.*>' 'do_on_click normal-release'
hook global InsertKey '<mouse:release:left:.*>' 'do_on_click insert-release'

# Increment the current click count--is it a single, double or triple click?
# Runs synchronously with wait_for_next_click.
define-command inc_click_count -override -hidden -params 1 %{
    eval %sh{
        echo "set-option global just_clicked $((kak_opt_just_clicked + 1))"
        if [ "$kak_opt_just_clicked" -eq 3 ]; then
            echo "set-option global just_clicked 1" 
        fi
    } 
    do_on_click %arg{1}
}

# For the default behaviour (select word/line on double/triple click),
# it isn't necessary to distinguish between a click press and a release;
# in fact, it's extremely important to send the *same* hook command twice,
# on both mouse-press and mouse-release.

# That's because our mouse:press hook is executed BEFORE kakoune processes the
# mouse click in the usual way, so if we simply tell kak to select a word when
# the mouse is pressed twice, what will happen is this:
 
# mouse:press triggers, and the word will be selected 
# a fraction of second passes, before mouse:release triggers
# mouse:release now triggers and de-selects the word, leaving you with a cursor

# The way around this is to instantly re-select the text with a mouse:release
# hook.
# However, if your custom hook doesn't select text, this may not be necessary
# Or, you may prefer to have your hook execute something on mouse-release.
# The delay will be noticeable, but this is still quite viable.
 
define-command do_on_click -override -hidden -params 1 %{
    eval %sh{
        mode=$1
        if   [ "$kak_opt_just_clicked" -eq 2 ]; then
            case $mode in
                normal)         echo "trigger-user-hook NormalDoubleClick" ;;
                insert)         echo "trigger-user-hook InsertDoubleClick" ;;
                normal-release) echo "trigger-user-hook NormalDoubleClick" ;;
                insert-release) echo "trigger-user-hook InsertDoubleClick" ;;
            esac
        elif [ "$kak_opt_just_clicked" -eq 3 ]; then
            case $mode in
                normal)         echo "trigger-user-hook NormalTripleClick" ;;
                insert)         echo "trigger-user-hook InsertTripleClick" ;;
                normal-release) echo "trigger-user-hook NormalTripleClick" ;;
                insert-release) echo "trigger-user-hook InsertTripleClick" ;;
            esac
        fi
    }
}

# The below routine is quite complicated.
# It will spawn a whole new subshell which runs in the background, which we do
# because the process must go to sleep (for a duration set by doubleclick_wait)

# Firstly, we save the current click_count.
# We then use 'kak -p "$kak_session"' to continue communicating with kak after
# our sneaking off into the background.
# After our background process wakes up, we send an entirely new shell command
# back to kak. We have to do this because we can't otherwise access the new
# value of click_count, but we also must return the value we saved.
# In this new shell command, by checking the current and prior values of
# click_cound, we can see whether a new click has occurred in the time we were
# asleep.
# If nothing's changed and no clicks were made, reset click status back to zero.
 
# If you click repeatedly in the same space, this routine spawns multiple times,
# but only the final spawn will end the click series.

define-command wait_for_next_click -override -hidden %{
    eval %sh{(
        n=$(( kak_opt_cur_click_count + 1 ))
        echo "set-option global cur_click_count $n" | kak -p "$kak_session"
        sleep $kak_opt_doubleclick_wait
        # evalception
        echo "eval %sh{
            if [ \$kak_opt_cur_click_count -eq $n ]; then
                echo 'set-option global just_clicked 0'
                echo 'set-option global cur_click_count 0'
            fi
        }" | kak -p "$kak_session" ) >/dev/null 2>&1 </dev/null &
    }
}
