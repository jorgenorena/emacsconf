;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun gdisplay-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'gdisplay-startup-time)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)
(unless (display-graphic-p)
    (xterm-mouse-mode 1))

;; Display line numbers
(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
		shell-mode-hook
		treemacs-mode-hook
		eshell-mode-hook
              eww-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

;;  Font
;; For mobile use 140
(set-face-attribute 'default nil :height 140)

;; Wrap on words
(global-visual-line-mode t)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Add custom scripts to path
(add-to-list 'load-path "~/.config/custom_emacs/scripts/")

;; "sane" defaults
(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))

; track recent filrs
(recentf-mode 1)

; command minibuffer history
(setq history-length 25)
(savehist-mode 1)

; remember cursor position
(save-place-mode 1)

; Move customization vars specified in graphical interface to a separate file
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; Avoid graphical dialog boxes
;(setq use-dialog-box nil)

; Watch open buffers for changes on disk
(global-auto-revert-mode 1)
; For dired and othet non-file buffers
(setq global-auto-revert-non-file-buffers t)

;; --- Package manager ---

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-verbose t)

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; --- THEME ---
;; preview it with M-x counsel-load-theme

(use-package doom-themes)
;;(load-theme 'doom-gruvbox t)

(use-package modus-themes
:ensure t
:config
;; Add all your customizations prior to loading the themes
(setq modus-themes-italic-constructs nil
      modus-themes-bold-constructs t
     modus-themes-to-toggle '(modus-vivendi-tinted modus-operandi-tinted))

;; Load the theme of your choice.
(load-theme 'modus-vivendi-tinted t))

;; Better modeline
  ;; doom modeline was too heavy for mobile devices, and had font problems, planning on using this instead
  ;; (use-package powerline
  ;;   :config (powerline-evil-theme)
  ;;   )

  ;; NOTE: The first time you load your configuration on a new machine, you'll
  ;; need to run the following command interactively so that mode line icons
  ;; display correctly:
  ;;
  ;; M-x all-the-icons-install-fonts
  (use-package all-the-icons)

  (use-package doom-modeline
    :init (doom-modeline-mode 1)
    :custom ((doom-modeline-height 15)))

;; rainbow mode for nested parentheses.
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Rainbow mode for colors,  e.g. #ffffff will have a white background
(use-package rainbow-mode
  :diminish
  :hook org-mode prog-mode)

(use-package edwina
  :ensure t
  :config
  (setq display-buffer-base-action '(display-buffer-below-selected))
  ;; (edwina-setup-dwm-keys)
  (edwina-mode 1))

;; A function used below
(defun reload-init-file ()
  (interactive)
  (load-file user-init-file))

;; A code to move buffers around
(require 'buffer-move)

;; --- KEY BINDINGS INC. EVIL LEADER ---
;; This may hurt performance in mobile. Try using evil-leader instead.

(use-package general
  :config
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
  (my/leader-keys
    "SPC" '(counsel-M-x :which-key "M-x")
    "." '(counsel-find-file :which-key "Find file")
    "TAB TAB" '(comment-line :which-key "Comment line")
    ;; Buffers
    "b" '(:ignore t :which-key "Bookmarks/Buffers")
    "b c" '(clone-indirect-buffer :which-key "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :which-key "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :which-key "Delete bookmark")
    "b b" '(counsel-ibuffer :which-key "Change buffer")
    "b i" '(ibuffer :which-key "List buffers")
    "b k" '(kill-this-buffer :which-key "Kill this buffer")
    "b K" '(kill-some-buffers :which-key "Kill multiple buffers")
    "b l" '(list-bookmarks :which-key "List bookmarks")
    "b m" '(bookmark-set :which-key "Set bookmark")
    "b n" '(next-buffer :which-key "Next buffer")
    "b p" '(previous-buffer :which-key "Previous buffer")
    "b r" '(revert-buffer :which-key "Reload buffer")
    "b R" '(rename-buffer :which-key "Rename buffer")
    "b s" '(basic-save-buffer :which-key "Save buffer")
    "b S" '(save-some-buffers :which-key "Save multiple buffers")
    "b w" '(bookmark-save :which-key "Save current bookmarks to bookmark file")
    ;; Eshell/evaluate
    "e" '(:ignore t :which-key "Eshell/Evaluate")    
    "e b" '(eval-buffer :which-key "Evaluate elisp in buffer")
    "e d" '(eval-defun :which-key "Evaluate defun containing or after point")
    "e e" '(eval-expression :which-key "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :which-key "Evaluate elisp expression before point")
    "e r" '(eval-region :which-key "Evaluate elisp in region")
    "e s" '(eshell :which-key "Eshell")
    ;; Org mode
    "m" '(:ignore t :which-key "Org")
    "m a" '(org-agenda :which-key "Org agenda")
    "m e" '(org-export-dispatch :which-key "Org export dispatch")
    "m i" '(org-toggle-item :which-key "Org toggle item")
    "m t" '(org-todo :which-key "Org todo")
    "m B" '(org-babel-tangle :which-key "Org babel tangle")
    "m T" '(org-todo-list :which-key "Org todo list")
    ;; Orgmode tables
    "m b" '(:ignore t :which-key "Tables")
    "m b -" '(org-table-insert-hline :which-key "Insert hline in table")
    ;; Orgmode dates
    "m d" '(:ignore t :which-key "Date/deadline")
    "m d t" '(org-time-stamp :which-key "Org time stamp")
    ;; Projects
    "p" '(projectile-command-map :which-key "Projectile")
    ;; Windows
    "w" '(:ignore t :which-key "Windows")
    "wc" '(evil-window-delete :which-key "Close window")
    "wn" '(evil-window-new :which-key "New window")
    "ws" '(evil-window-split :which-key "Horizontal split")
    "wv" '(evil-window-vsplit :which-key "Vertical split")
    "wh" '(evil-window-left :which-key "Move to window left")
    "wj" '(evil-window-down :which-key "Move to window down")
    "wk" '(evil-window-up :which-key "Move to window up")
    "wl" '(evil-window-right :which-key "Move to window right")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right")
    ;; Help!
    "h" '(:ignore t :which-key "Help")
    "h a" '(counsel-apropos :which-key "Apropos")
    "h b" '(describe-bindings :which-key "Describe bindings")
    "h c" '(describe-char :which-key "Describe character under cursor")
    "h d" '(:ignore t :which-key "Emacs documentation")
    "h d a" '(about-emacs :which-key "About Emacs")
    "h d d" '(view-emacs-debugging :which-key "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :which-key "View Emacs FAQ")
    "h d m" '(info-emacs-manual :which-key "The Emacs manual")
    "h d n" '(view-emacs-news :which-key "View Emacs news")
    "h d o" '(describe-distribution :which-key "How to obtain Emacs")
    "h d p" '(view-emacs-problems :which-key "View Emacs problems")
    "h d t" '(view-emacs-todo :which-key "View Emacs todo")
    "h d w" '(describe-no-warranty :which-key "Describe no warranty")
    "h e" '(view-echo-area-messages :which-key "View echo area messages")
    "h f" '(describe-function :which-key "Describe function")
    "h F" '(describe-face :which-key "Describe face")
    "h g" '(describe-gnu-project :which-key "Describe GNU Project")
    "h i" '(info :which-key "Info")
    "h I" '(describe-input-method :which-key "Describe input method")
    "h k" '(describe-key :which-key "Describe key")
    "h l" '(view-lossage :which-key "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :which-key "Describe language environment")
    "h m" '(describe-mode :which-key "Describe mode")
    "h r" '(:ignore t :which-key "Reload")
    "h t" '(tldr :which-key "TLDR docs")
    "h v" '(describe-variable :which-key "Describe variable")
    "h w" '(where-is :which-key "Prints keybinding for command if set")
    "h x" '(describe-command :which-key "Display full documentation for command")
    "hrr" '(reload-init-file :which-key "Reload emacs config")
    ;; Toggles
    "t"  '(:ignore t :which-key "Toggles")
    "tt" '(modus-themes-toggle :which-key "Toggle light/dark theme")
    "tl" '(display-line-numbers-mode :which-key "Toggle line numbers")
    "tv" '(vterm-toggle :which-key "Toggle vterm")
    "tr" '(rainbow-mode :which-key "Toggle rainbow mode")
    ;; Find
    "f" '(:ignore t :which-key "Find")
    "ff" '(counsel-find-file :which-key "Find file")
    "fr" '(counsel-recentf :which-key "Recent files")
    ;; Dired
    "d" '(:ignore t :which-key "Dired")
    "d d" '(dired :which-key "Open dired")
    "d j" '(dired-jump :which-key "Dired jump to current")
    "d n" '(neotree-dir :which-key "Open directory in neotree")
    "d p" '(peep-dired :which-key "Peep-dired")
    ;; Git
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file")
  ))

;; --- EVIL MODE ---

(use-package evil
  :init
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq evil-want-integration t) ; This is optional, required for some packages
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state) ;; make C-g also exit input mode
  
  ;; set this so j and k go down in lines you can see, not lines in the original file
  ;(evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "<down>" 'evil-next-visual-line)
  ;(evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-global-set-key 'motion "<up>" 'evil-previous-visual-line)
  
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(use-package evil-multiedit
  :after evil
  :config
  (evil-multiedit-default-keybinds))

(use-package evil-snipe
  :after evil
  :init
  (evil-snipe-mode 1))  ; Globally enable evil-snipe

(use-package evil-terminal-cursor-changer
  :config
  (evil-terminal-cursor-changer-activate) ; or (etcc-on)
  )

;;   ;; --- Which key ---
  ;; (use-package which-key
  ;;   :defer 0
  ;;   :diminish which-key-mode
  ;;   :config
  ;;   (which-key-mode)
  ;;   (setq which-key-idle-delay 1))

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish which-key-mode
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))

;; --- Ivy command completion ---
;; Maybe try other packages and test for performance

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         :map ivy-switch-buffer-map
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil) ;; don't start searches with ^
  )

(use-package ivy-prescient
  :after counsel
  :config
  (ivy-prescient-mode 1))

;; additional help from helpful
(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(defun org-font-setup ()

  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
			  '(("^ *\\([-]\\) "
			     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  ;; Consider removing all this visual stuff for mobile
  (dolist (face '((org-level-1 . 1.4)
		  (org-level-2 . 1.3)
		  (org-level-3 . 1.2)
		  (org-level-4 . 1.1)
		  (org-level-5 . 1.05)
		  (org-level-6 . 1.05)
		  (org-level-7 . 1.05)
		  (org-level-8 . 1.05)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun org-journal-find-location () 
  ;; Open today's journal, but specify a non-nil prefix argument in order to 
  ;; inhibit inserting the heading; org-capture will insert the heading. (org-journal-new-entry t) 
  (unless (eq org-journal-file-type 'daily) (org-narrow-to-subtree)) 
  (goto-char (point-max))) 


;; --- ORG MODE! ---

(setq evil-want-C-i-jump nil)  

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . org-font-setup)
  :config
  (setq org-ellipsis " ▾")

  ;; Avoid strange indentation behavior orgmode
  (electric-indent-mode -1) ;; if this doesn't work, try doing it after the hook below
  (setq org-edit-src-content-indentation 0) ;; 

  ;; What does this do?
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  ;; Which files to use for the agenda.
  (setq org-agenda-files
        '("~/org/Tasks.org"
          "~/org/Schedule.org"
          "~/org/Dates.org"))

  ;; Custom To do keywords / states
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" "|" "DONE(d!)")))

  ;; Files to use for refiling
  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))
  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  ;; Tags
  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/org/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal entry" plain (function org-journal-find-location) 
         "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?" 
         :jump-to-captured t :immediate-finish t)))

  ;; Capture keybindings
  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (org-font-setup))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun gorg-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . gorg-mode-visual-fill))

;; Function to set up RET key binding in normal mode
(defun my/org-mode-evil-setup ()
  "Custom configurations for org-mode with evil-mode."
  (evil-define-key 'normal org-mode-map (kbd "RET") 'org-open-at-point)
  (evil-define-key 'normal org-mode-map (kbd "C-i") 'org-cycle))

;; Add the function to the org-mode hook
(add-hook 'org-mode-hook 'my/org-mode-evil-setup)

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(with-eval-after-load 'org ;defer until org loads
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))

  (org-babel-do-load-languages
      'org-babel-load-languages
	'((emacs-lisp . t)
	  (python . t)
      (jupyter . t)
      ;(ipython . t)
      (julia-vterm . t)
    )) ;See the python section
)

(use-package org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package org-journal 
  :ensure t 
  :defer t 
  :init ;; Change default prefix key
    ; needs to be set before loading org-journal 
    (setq org-journal-prefix-key "C-c j ") 
  :config 
    (setq org-journal-dir "~/org/journal/" 
          org-journal-date-format "%A, %d %B %Y"
          org-journal-file-type 'monthly))

(defun glsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . glsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp-mode)

(use-package lsp-ivy
  :after lsp-mode)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)
  :commands 'dap-debug
  :config

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :which-key "debugger")))

(use-package flycheck
  :defer t
  :after lsp-mode
  :diminish
  :init (global-flycheck-mode))

(use-package yasnippet
  :after lsp-mode 
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package python-mode
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (setq lsp-pylsp-server-command "pylsp")
  (setq lsp-pylsp-plugins-jedi-completion-enabled t)  ; Enable Jedi completion setup
  (setq lsp-pylsp-plugins-pylint-enabled t)           ; Enable Pylint for linting
  (setq lsp-pylsp-plugins-flake8-enabled t)           ; Optionally, enable Flake8 for linting
  (require 'dap-python)
  (dap-python-setup))

(use-package conda
  :after python-mode
  :config
  (setq conda-anaconda-home (expand-file-name "~/Programs/miniforge3/"))
  (setq conda-env-home-directory (expand-file-name "~/Programs/miniforge3/"))
  (setq conda-env-subdirectory "envs")

  (unless (getenv "CONDA_DEFAULT_ENV")
    (conda-env-activate "base")))

(use-package company-anaconda
  :after '(company conda)
  :config
    '(add-to-list 'company-backends 'company-anaconda)
)

(add-hook 'python-mode-hook 'anaconda-mode)

(use-package jupyter)

(require 'my-jupyter-utils)

;; LUA support
(use-package lua-mode)

;; LaTeX support
(use-package tex
  :ensure auctex
  :config
    ;; Enable "document parsing" (suggested by the manual)
    (setq TeX-auto-save t) 
    (setq TeX-parse-self t)
    (setq lsp-tex-server 'texlab))

(use-package cdlatex
  :after tex)

(use-package evil-tex
  :after tex)

(use-package cc-mode
  :hook (c-mode-common . cc-mode-setup)
  :custom
  (c-basic-offset 4)
  (c-default-style "linux")
  :config
  (defun cc-mode-setup ()
    (c-set-offset 'case-label '+)
    (setq-local comment-start "//"
                comment-end ""
                tab-width 4)))

(use-package julia-ts-mode)
(use-package julia-vterm)
;;(add-hook 'julia-mode-hook #'julia-vterm-mode)
(use-package ob-julia-vterm)
(setq lsp-julia-default-environment "~/.julia/environments/v1.10")
(use-package julia-snail
  :ensure t
  :hook (julia-mode . julia-snail-mode))

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  ;(when (file-directory-p "~/Projects/Code")
  ;  (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

;; Magit for git interface
(use-package magit
  :commands magit-status ;add more commands if needed
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

;; Git time machine to travel beetween commits.
(use-package git-timemachine
  :after git-timemachine
  :hook (evil-normalize-keymaps . git-timemachine-hook)
  :config
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
)

(use-package vterm
    :commands vterm
    :config
    (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
    ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
    (setq vterm-max-scrollback 10000))

(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3))))

(defun gconfigure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
	eshell-buffer-maximum-lines 10000
	eshell-hist-ignoredups t
	eshell-scroll-to-bottom-on-input t
    eshell-destroy-buffer-when-process-dies t
    eshell-rc-script (concat user-emacs-directory "eshell/profile")
    eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
    ))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . gconfigure-eshell)
  :config

  (with-eval-after-load 'esh-opt
	(setq eshell-destroy-buffer-when-process-dies t)
	(setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-algho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

;; Make dired use a single buffer
(use-package dired-single 
  :commands (dired dired-jump))

;; Make dired show icons
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; Specify which program should open each file
;; look into open-xdg to open using default linux apps
(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
				("mkv" . "mpv"))))

;; ;; Hide dotfiles
;; (use-package dired-hide-dotfiles
;;   :hook (dired-mode . dired-hide-dotfiles-mode)
;;   :config
;;   (evil-collection-define-key 'normal 'dired-mode-map
;;     "H" 'dired-hide-dotfiles-mode))

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
