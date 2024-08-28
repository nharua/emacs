;; Start-up options
(setq warning-minimum-level :emergency)
(setq frame-title-format "%b")
(setq inhibit-startup-screen t)
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(scroll-bar-mode -1)           ; Disable visible scrollbar
(tool-bar-mode -1)             ; Disable the toolbar
(tooltip-mode -1)              ; Disable tooltips
(set-fringe-mode 10)           ; Give some breathing room
;; (menu-bar-mode -1)             ; Disable the menu bar
(global-hl-line-mode 1)        ; Highline current line
(setq visible-bell t)          ; Setup the visible bell
(recentf-mode 1)               ; Remember rently edited files, using "M-x recentf-open-file"
(save-place-mode 1)            ; Remember and restore the last cursor location of opened filed
(global-auto-revert-mode 1)    ; Auto revert buffers for changed files
(savehist-mode 1)              ; Remember minibuf command lists
(setq history-length 25)       ; Numbers of command that remembered
(setq-default indent-tabs-mode nil)    ; Prevent Extraneous Tabs

;; Merge from old config
(defun duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")

  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))

  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion

      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))

      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )

      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg))
(global-set-key (kbd "C-d") 'duplicate-line)

;; Merge from old config
;; Write backups to ~/.emacs.d/backup/
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups
      kept-new-versions      20 ; How many of the newest versions to keep
      kept-old-versions      5) ; And how many of the old versions to keep

;; Merge from old config
;; Custom function to remove trailing whitespace
(defun my-prog-nuke-trailing-whitespace ()
  "Remove trailing whitespace in programming modes."
  (when (derived-mode-p 'prog-mode)
    (delete-trailing-whitespace)))
;; Remove trailing whitespace before saving
(add-hook 'before-save-hook 'my-prog-nuke-trailing-whitespace)

;; Custom function to convert TAB to SPACE
(defun remove-hard-tabs ()
  "Replace hard tabs with spaces before saving the file."
  (when (derived-mode-p 'prog-mode) ; Only apply to programming modes
    (untabify (point-min) (point-max))))
(add-hook 'before-save-hook 'remove-hard-tabs)

;; ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341
;; ;; Setup this variable to make package install with old TLS
;; ;; This option should be comment when emacs version > 27.1
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; ;; Disable signature checking temporarily if necessary
(setq package-check-signature nil)

;; Set font and font size
;; M-x describe-font to list all available font
;; (set-face-attribute 'default nil :font "JetBrainsMonoNL Nerd Font Mono" :height 120)
(set-face-attribute 'default nil :font "DejaVu Sans Mono" :height 120)

;; Load dark theme
(load-theme 'wombat)

;; Global Key Binding
;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; Merge from old config
(global-set-key "\C-z" 'undo-only)
(global-set-key (kbd "<f12>") 'save-buffer)
(global-set-key (kbd "<C-tab>") 'other-window)
(global-set-key (kbd "<f4>") 'goto-line)
(global-set-key (kbd "<f5>") 'query-replace)
(global-set-key [f10] 'align-regexp)
(global-set-key [f9] "\C-u 'align-regexp")
(global-set-key [C-mouse-4] '(lambda () (interactive) (text-scale-increase 1)))
(global-set-key [C-mouse-5] '(lambda () (interactive) (text-scale-decrease 1)))

;; Show line number
(global-display-line-numbers-mode t)
;; (setq display-line-numbers-type 'relative)
;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
(column-number-mode)

;; Package manager
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
;; (add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t)
(package-initialize)

;; If you configure emacs from scratch, please comment out these lines
(unless package-archive-contents
  (package-refresh-contents))

;; Setup use-package if it's not exist
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . counsel-minibuffer-history)
	 )
  )

;; Advance search mode
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; Advance GUI Mode
;; NOTE: The first time you load your configuration on a new machine,
;; you need to run the following command interactively sothat mode line
;; icons display correctly
;;
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

;; Load more theme
(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15))
  )

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

;; A better Emacs *help* buffer
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

;; Project management and navigation
(use-package projectile
  :diminish projectile-mode
  :config
  ;; Set this config to fix .projectile ignore file
  ;; Read more https://github.com/bbatsov/projectile/issues/1322
  (setq projectile-indexing-method 'hybrid)
  (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  ;; (when (file-directory-p "~/workDir/local")
  ;;   (setq projectile-project-search-path '("~/workDir/local")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Org Mode
;; Org Mode Configuration ------------------------------------------------------
(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))
(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

;; Org Mode setup
(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-files
	'("~/.emacs.d/Notes/todo.org"))
  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
  (efs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

;; Company Mode
;; Install and configure Company mode
(use-package company
  :config
  (setq company-idle-delay 0.2  ;; How long to wait before popping up
        company-minimum-prefix-length 1  ;; Show completion after a single character
        company-tooltip-align-annotations t)
  (global-company-mode t))  ;; Enable company mode globally

;; LSP Mode
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c C-l")
  :config
  (setq lsp-enable-which-key-integration t
        lsp-prefer-flymake nil
        lsp-pylsp-plugins-autopep8-enabled nil
        lsp-pylsp-plugins-yapf-enabled nil
        lsp-pylsp-plugins-black-enabled t)
 )

(use-package flycheck
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; optionally
(use-package lsp-ui
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode))
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;; LSP with verible-verilog
;; (require 'lsp-mode)
;; (add-to-list 'lsp-language-id-configuration '(verilog-mode . "verilog"))
;; (lsp-register-client
;;  (make-lsp-client :new-connection (lsp-stdio-connection "verible-verilog-ls")
;;                   :major-modes '(verilog-mode)
;;                   :server-id 'verible-ls))

;; (add-hook 'verilog-mode-hook 'lsp)

;; LSP with verible-verilog
(require 'lsp-mode)

(defun my-lsp-verible-verilog-ls ()
  "Setup LSP for Verible Verilog LS with custom rules."
  (let ((rules-config (expand-file-name "~/.emacs.d/verible/.rules.verible_lint")))
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection
                       (list "verible-verilog-ls" (concat "--rules_config=" rules-config)))
      :major-modes '(verilog-mode)
      :server-id 'verible-ls))))

(my-lsp-verible-verilog-ls)

(add-hook 'verilog-mode-hook 'lsp)

;; Verilog-Mode
;; Load local verilog-mode
;; Define a macro to use verible-verilog-format to format a verilog/systemverilog file
(defun my-verilog-format-buffer ()
  "Format the current buffer using verible-verilog-format."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      ;; Save the buffer before formatting
      (save-buffer)
      ;; Run verible-verilog-format --inplace on the file
      (shell-command (concat "verible-verilog-format --inplace " filename))
      ;; Revert the buffer to reflect changes
      (revert-buffer t t t)
      (message "Formatted %s" filename))))

;; Define a macro to use verible-verilog-lint to check syntax a verilog/systemverilog file
(defun my-verilog-lint-buffer ()
  "Lint the current buffer using verible-verilog-lint and display results in a right buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (rules-file (expand-file-name "~/.emacs.d/verible/.rules.verible_lint"))
        (current-window (selected-window)))
    (when filename
      ;; Save the buffer before linting
      (save-buffer)
      ;; Split the window and select the right one
      (split-window-right)
      (other-window 0)
      ;; Run verible-verilog-lint with the configuration file
      (compile (concat "verible-verilog-lint --rules_config='" rules-file "' " filename))
      ;; Select the original window
      (select-window current-window)
      (message "Linted %s" filename))))

(defun my-verilog-mode-setup ()
  "Custom configurations for verilog-mode."
  ;; Set C-c i to run verilog-indent-buffer
  (define-key verilog-mode-map (kbd "C-c i") 'verilog-indent-buffer)
  ;; Set C-c f to run my-verilog-format-buffer
  (define-key verilog-mode-map (kbd "C-c f") 'my-verilog-format-buffer)
  ;; Set C-c l to run my-verilog-lint-buffer
  (define-key verilog-mode-map (kbd "C-c l") 'my-verilog-lint-buffer)
  ;; (set-face-attribute 'font-lock-comment-face nil :foreground "green")
  (font-lock-mode 1))  ;; Ensure font-lock-mode is enabled

;; Add the directory containing verilog-mode.el to the load-path
(add-to-list 'load-path "~/.emacs.d/lisp/")
;; Load the verilog-mode.el file
(load-file "~/.emacs.d/lisp/verilog-mode.el")
;; Load verilog mode only when needed
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
;; Any files that end in .v, .dv or .sv should be in verilog mode
(add-to-list 'auto-mode-alist '("\\.[ds]?va?h?\\'" . verilog-mode))
(add-hook 'verilog-mode-hook 'my-verilog-mode-setup)

;; Additional configuration settings for verilog-mode
(setq safe-local-variable-values
      '((verilog-auto-inst-sort . non-nil)
        (verilog-auto-inst-sort)
        (verilog-auto-inst-template-required)
        (verilog-align-decl-expr-comments)
        (verilog-auto-sense-define-constant . t)))

(setq show-paren-mode t)
(setq verilog-align-decl-expr-comments nil)
(setq verilog-auto-inst-param-value t)
(setq verilog-auto-inst-sort nil)
(setq verilog-auto-inst-template-numbers nil)
(setq verilog-auto-inst-template-required nil)
(setq verilog-auto-newline t)
(setq verilog-auto-reset-widths 'unbased)
(setq verilog-auto-save-policy nil)
(setq verilog-auto-template-warn-unused nil)
(setq verilog-auto-wire-type "logic")
(setq verilog-typedef-regexp "_t$")
(setq verilog-tab-always-indent nil)

;; Insert header
(use-package yasnippet
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode 1)
    (add-hook 'verilog-mode-hook
            (lambda ()
              (yas-minor-mode 1)
              ;; Bind TAB key to yasnippet
              (local-set-key (kbd "C-c y") 'yas-expand)))
  )

;; Python Mode
;; Python Mode: we're using Python - Treesitter - eglot as client - pylsp as server
;; Ref based on https://www.youtube.com/watch?v=SbTzIt6rISg
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))

(use-package python
  ;; :hook ((python-ts-mode . eglot-ensure))
  :hook ((python-ts-mode . lsp-deferred))
  ;; :mode (("\\.py\\'" . python-ts-mode))
  :bind (:map python-ts-mode-map
              ("C-c f" . lsp-format-buffer))
  )

(use-package highlight-indent-guides
  :ensure t
  :hook (python-ts-mode . highlight-indent-guides-mode)
  :config
  (set-face-background 'highlight-indent-guides-odd-face "darkgray")
  (set-face-background 'highlight-indent-guides-even-face "dimgray")
  (set-face-foreground 'highlight-indent-guides-character-face "white")
  (setq highlight-indent-guides-method 'character))

;; Save custom set to emacs-custom.el
(setq custom-file "~/.emacs.d/emacs-custom.el")
(load custom-file t)
