#!/usr/bin/env bash

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value
	option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

is_vim=$(get_tmux_option "@tmux-nvim-condition" "ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\.?(view|n?vim?x?)(-wrapped)?(diff)?$'")

# navigation
#

navigation_enabled=$(get_tmux_option "@tmux-nvim-navigation" true)
navigation_cycle=$(get_tmux_option "@tmux-nvim-navigation-cycle" true)
navigation_kb_left=$(get_tmux_option "@tmux-nvim-navigation-keybinding-left" 'C-h')
navigation_kb_down=$(get_tmux_option "@tmux-nvim-navigation-keybinding-down" 'C-j')
navigation_kb_up=$(get_tmux_option "@tmux-nvim-navigation-keybinding-up" 'C-k')
navigation_kb_right=$(get_tmux_option "@tmux-nvim-navigation-keybinding-right" 'C-l')
navigation_kb_next=$(get_tmux_option "@tmux-nvim-navigation-keybinding-next" '')
navigation_kb_previous=$(get_tmux_option "@tmux-nvim-navigation-keybinding-previous" '')
navigation_cmd_left='select-pane -L'
navigation_cmd_down='select-pane -D'
navigation_cmd_up='select-pane -U'
navigation_cmd_right='select-pane -R'
navigation_cmd_next='select-window -n'
navigation_cmd_previous='select-window -p'

if $navigation_enabled; then
	if $navigation_cycle; then
		tmux bind-key -n "$navigation_kb_left" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_left" \
			"$navigation_cmd_left"

		tmux bind-key -n "$navigation_kb_down" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_down" \
			"$navigation_cmd_down"

		tmux bind-key -n "$navigation_kb_up" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_up" \
			"$navigation_cmd_up"

		tmux bind-key -n "$navigation_kb_right" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_right" \
			"$navigation_cmd_right"

		if [ -n "$navigation_kb_next" ]; then
			tmux bind-key -n "$navigation_kb_next" \
				if-shell "$is_vim" \
				"send-keys $navigation_kb_next" \
				"$navigation_cmd_next"
		fi

		if [ -n "$navigation_kb_previous" ]; then
			tmux bind-key -n "$navigation_kb_previous" \
				if-shell "$is_vim" \
				"send-keys $navigation_kb_previous" \
				"$navigation_cmd_previous"
		fi

		tmux bind-key -T copy-mode-vi "$navigation_kb_left" \
			"$navigation_cmd_left"

		tmux bind-key -T copy-mode-vi "$navigation_kb_down" \
			"$navigation_cmd_down"

		tmux bind-key -T copy-mode-vi "$navigation_kb_up" \
			"$navigation_cmd_up"

		tmux bind-key -T copy-mode-vi "$navigation_kb_right" \
			"$navigation_cmd_right"

		tmux bind-key -T copy-mode-vi "$navigation_kb_next" \
			"$navigation_cmd_next"

		tmux bind-key -T copy-mode-vi "$navigation_kb_previous" \
			"$navigation_cmd_previous"
	else
		tmux bind-key -n "$navigation_kb_left" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_left" \
			"if -F '#{pane_at_left}' '' \
				'$navigation_cmd_left'"

		tmux bind-key -n "$navigation_kb_down" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_down" \
			"if -F '#{pane_at_bottom}' '' \
				'$navigation_cmd_down'"

		tmux bind-key -n "$navigation_kb_up" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_up" \
			"if -F '#{pane_at_top}' '' \
				'$navigation_cmd_up'"

		tmux bind-key -n "$navigation_kb_right" \
			if-shell "$is_vim" \
			"send-keys $navigation_kb_right" \
			"if -F '#{pane_at_right}' '' \
				'$navigation_cmd_right'"

		if [ -n "$navigation_kb_next" ]; then
			tmux bind-key -n "$navigation_kb_next" \
				if-shell "$is_vim" \
				"send-keys $navigation_kb_next" \
				"if -F '#{window_end_flag}' '' \
					'$navigation_cmd_next'"
		fi

		if [ -n "$navigation_kb_previous" ]; then
			tmux bind-key -n "$navigation_kb_previous" \
				if-shell "$is_vim" \
				"send-keys $navigation_kb_previous" \
				"if 'test #{window_index} -gt  #{base-index}' \
					'$navigation_cmd_previous'"
		fi

		tmux bind-key -T copy-mode-vi "$navigation_kb_left" \
			if -F '#{pane_at_left}' '' \
			"$navigation_cmd_left"

		tmux bind-key -T copy-mode-vi "$navigation_kb_down" \
			if -F '#{pane_at_bottom}' '' \
			"$navigation_cmd_down"

		tmux bind-key -T copy-mode-vi "$navigation_kb_up" \
			if -F '#{pane_at_top}' '' \
			"$navigation_cmd_up"

		tmux bind-key -T copy-mode-vi "$navigation_kb_right" \
			if -F '#{pane_at_right}' '' \
			"$navigation_cmd_right"

		if [ -n "$navigation_kb_next" ]; then
			tmux bind-key -T copy-mode-vi "$navigation_kb_next" \
				if -F '#{window_end_flag}' '' \
				"$navigation_cmd_next"
		fi

		if [ -n "$navigation_kb_previous" ]; then
			tmux bind-key -T copy-mode-vi "$navigation_kb_previous" \
				if 'test #{window_index} -gt  #{base-index}' \
				"$navigation_cmd_previous"
		fi
	fi
fi

# resize
#

resize_enabled=$(get_tmux_option "@tmux-nvim-resize" true)
resize_step_x=$(get_tmux_option "@tmux-nvim-resize-step-x" 1)
resize_step_y=$(get_tmux_option "@tmux-nvim-resize-step-y" 1)
resize_kb_left=$(get_tmux_option "@tmux-nvim-resize-keybinding-left" 'M-h')
resize_kb_down=$(get_tmux_option "@tmux-nvim-resize-keybinding-down" 'M-j')
resize_kb_up=$(get_tmux_option "@tmux-nvim-resize-keybinding-up" 'M-k')
resize_kb_right=$(get_tmux_option "@tmux-nvim-resize-keybinding-right" 'M-l')

if $resize_enabled; then
	tmux bind -n "$resize_kb_left" if-shell "$is_vim" "send-keys $resize_kb_left" "resize-pane -L $resize_step_x"
	tmux bind -n "$resize_kb_down" if-shell "$is_vim" "send-keys $resize_kb_down" "resize-pane -D $resize_step_y"
	tmux bind -n "$resize_kb_up" if-shell "$is_vim" "send-keys $resize_kb_up" "resize-pane -U $resize_step_y"
	tmux bind -n "$resize_kb_right" if-shell "$is_vim" "send-keys $resize_kb_right" "resize-pane -R $resize_step_x"

	tmux bind-key -T copy-mode-vi "$resize_kb_left" resize-pane -L "$resize_step_x"
	tmux bind-key -T copy-mode-vi "$resize_kb_down" resize-pane -D "$resize_step_y"
	tmux bind-key -T copy-mode-vi "$resize_kb_up" resize-pane -U "$resize_step_y"
	tmux bind-key -T copy-mode-vi "$resize_kb_right" resize-pane -R "$resize_step_x"
fi

# swap
#

swap_enabled=$(get_tmux_option "@tmux-nvim-swap" true)
swap_cycle=$(get_tmux_option "@tmux-nvim-swap-cycle" false)
swap_kb_left=$(get_tmux_option "@tmux-nvim-swap-keybinding-left" 'C-M-h')
swap_kb_down=$(get_tmux_option "@tmux-nvim-swap-keybinding-down" 'C-M-j')
swap_kb_up=$(get_tmux_option "@tmux-nvim-swap-keybinding-up" 'C-M-k')
swap_kb_right=$(get_tmux_option "@tmux-nvim-swap-keybinding-right" 'C-M-l')

if $swap_enabled; then
	if $swap_cycle; then
		tmux bind-key -n "$swap_kb_left" if-shell "$is_vim" "send-keys $swap_kb_left" 'swap-pane -s "{left-of}"'
		tmux bind-key -n "$swap_kb_down" if-shell "$is_vim" "send-keys $swap_kb_down" 'swap-pane -s "{down-of}"'
		tmux bind-key -n "$swap_kb_up" if-shell "$is_vim" "send-keys $swap_kb_up" 'swap-pane -s "{up-of}"'
		tmux bind-key -n "$swap_kb_right" if-shell "$is_vim" "send-keys $swap_kb_right" 'swap-pane -s "{right-of}"'

		tmux bind-key -T copy-mode-vi "$swap_kb_left" swap-pane -s "{left-of}"
		tmux bind-key -T copy-mode-vi "$swap_kb_down" swap-pane -s "{down-of}"
		tmux bind-key -T copy-mode-vi "$swap_kb_up" swap-pane -s "{up-of}"
		tmux bind-key -T copy-mode-vi "$swap_kb_right" swap-pane -s "{right-of}"
	else
		tmux bind-key -n "$swap_kb_left" if-shell "$is_vim" "send-keys $swap_kb_left" "if -F '#{pane_at_left}' '' 'swap-pane -s \"{left-of}\"'"
		tmux bind-key -n "$swap_kb_down" if-shell "$is_vim" "send-keys $swap_kb_down" "if -F '#{pane_at_bottom}' '' 'swap-pane -s \"{down-of}\"'"
		tmux bind-key -n "$swap_kb_up" if-shell "$is_vim" "send-keys $swap_kb_up" "if -F '#{pane_at_top}' '' 'swap-pane -s \"{up-of}\"'"
		tmux bind-key -n "$swap_kb_right" if-shell "$is_vim" "send-keys $swap_kb_right" "if -F '#{pane_at_right}' '' 'swap-pane -s \"{right-of}\"'"

		tmux bind-key -T copy-mode-vi "$swap_kb_left" "if -F '#{pane_at_left}' '' 'swap-pane -s \"{left-of}\"'"
		tmux bind-key -T copy-mode-vi "$swap_kb_down" "if -F '#{pane_at_bottom}' '' 'swap-pane -s \"{down-of}\"'"
		tmux bind-key -T copy-mode-vi "$swap_kb_up" "if -F '#{pane_at_top}' '' 'swap-pane -s \"{up-of}\"'"
		tmux bind-key -T copy-mode-vi "$swap_kb_right" "if -F '#{pane_at_right}' '' 'swap-pane -s \"{right-of}\"'"
	fi
fi
