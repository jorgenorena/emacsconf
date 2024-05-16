;;; init.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 Jorge
;;
;; Author: Jorge <jorge@jorge-XENIA-15>
;; Maintainer: Jorge <jorge@jorge-XENIA-15>
;; Created: mayo 16, 2024
;; Modified: mayo 16, 2024
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/jorge/init
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; ---------------- EVIL MODE -----------------------

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ; This is optional, required for some packages
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package evil-leader
  :after evil
  :ensure t
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "e" 'find-file
    "b" 'switch-to-buffer
    "k" 'kill-buffer))

(use-package evil-commentary
  :after evil
  :ensure t
  :config
  (evil-commentary-mode))

(use-package evil-multiedit
  :after evil
  :ensure t
  (evil-multiedit-default-keybinds))

(use-package evil-snipe
  :ensure t
  :init
  (evil-snipe-mode 1))  ; Globally enable evil-snipe


(provide 'init)
;;; init.el ends here
