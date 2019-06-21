;;; org-sql-test.el --- Tests for org-sql

;;; org-sql-test.el ends here

(require 'dash)

;; TODO ...wettest code ever :(
(ert-deftest org-sql/files-all ()
  "Should return all files from `org-sql-files'."
  (with-sandbox
   (let ((org-sql-files (->> '("arch1.org_archive"
                               "subdir"
                               "test1.org"
                               "error.org")
                             (--map (f-join org-directory it))))
         (real-files (f-files org-directory nil t)))
     (should (eq '() (-difference (org-sql-files) real-files))))))

(ert-deftest org-sql/files-exist ()
  "Should return all files from `org-sql-files' but only those that
exist."
  (with-sandbox
   (let* ((org-sql-files (->> '("arch1.org_archive"
                                "subdir"
                                "test1.org"
                                "error.org"
                                "fake.org")
                              (--map (f-join org-directory it))))
          (real-files (f-files org-directory nil t)))
     (should (eq '() (-difference (org-sql-files) real-files))))))

;; TODO ...there's a better way to do this, right?
(ert-deftest org-sql/extract-files ()
  "Should return a valid accumulator."
  (with-sandbox
   (let* ((test-file (f-join org-directory "test1.org"))
          (test-file-size (f-size test-file))
          (test-md5-sum "some-md5")
          (test-cell (cons test-file test-md5-sum)))
     (should (equal
              `((files
                 ,(list :file_path test-file
                        :md5 test-md5-sum
                        :size test-file-size))
                (headlines
                 ,(list :file_path test-file
                        :headline_offset 1
                        :tree_path nil
                        :headline_text "small test headline"
                        :keyword nil
                        :effort nil
                        :priority nil
                        :archived 0
                        :commented 0
                        :content nil)))
              (org-sql--extract-file test-cell nil))))))
  
(ert-deftest org-sql/plist-get-keys-valid ()
  "Should return the keys of a plist."
  (should (equal '(:one two "three") (org-sql--plist-get-keys
                                      '(:one 1 two 2 "three" 3)))))

(ert-deftest org-sql/plist-get-keys-nil ()
  "Should return nil if no plist given."
  (should-not (org-sql--plist-get-keys nil)))

(ert-deftest org-sql/plist-get-vals-valid ()
  "Should return the values of a plist."
  (should (equal '(1 "2" :3) (org-sql--plist-get-vals
                              '(:one 1 :two "2" :three :3)))))

(ert-deftest org-sql/plist-get-vals-nil ()
  "Should return nil if no plist given."
  (should-not (org-sql--plist-get-vals nil)))

(ert-deftest org-sql/to-plist-blank ()
  "Should return nothing if given an empty string or nil."
  (should-not (org-sql--to-plist "" '())))

(ert-deftest org-sql/to-plist-nil ()
  "Should given an error if given nil."
  (should-error (org-sql--to-plist nil '())))

(ert-deftest org-sql/to-plist-valid ()
  "Should give a list of plists for a given SQL-formatted input.
Input might be multiple lines."
  (should (equal '((:one "1" :two "2" :three "3")
                   (:one "4" :two "5" :three "6"))
                   (org-sql--to-plist "1|2|3\n4|5|6"
                                    '(:one :two :three)))))

(ert-deftest org-sql/escape-text-nil ()
  "Should give an error if given nil"
  (should-error (org-sql--escape-text nil)))

(ert-deftest org-sql/escape-text-blank ()
  "Should return a single-quoted blank if given a blank."
  (should (equal "''" (org-sql--escape-text ""))))

(ert-deftest org-sql/escape-text-newline ()
  "Should insert a '||char(10)||' for every \n character."
  (should (equal "''||char(10)||''" (org-sql--escape-text "\n"))))

(ert-deftest org-sql/escape-text-single-quote ()
  "Should insert two single quotes for every quote."
  (should (equal "''''" (org-sql--escape-text "'"))))

(ert-deftest org-sql/to-string-nil ()
  "Should return \"NULL\" when given nil."
  (should (equal "NULL" (org-sql--to-string nil))))

(ert-deftest org-sql/to-string-string ()
  "Should return an escaped string when given a string."
  (let ((s "'a'\n'b'"))
    (should (equal (org-sql--escape-text s) (org-sql--to-string s)))))

(ert-deftest org-sql/to-string-number ()
  "Should return a stringified number when given a number."
  (should (equal "1" (org-sql--to-string 1))))

(ert-deftest org-sql/to-string-symbol ()
  "Should return the symbol's escaped name when given a symbol."
  (should (equal (org-sql--escape-text "abc")
                 (org-sql--to-string 'abc))))

(ert-deftest org-sql/kw-to-colname-nil ()
  "Should return error when given nil."
  (should-error (org-sql--kw-to-colname nil)))

(ert-deftest org-sql/kw-to-colname-non-keyword ()
  "Should return error when not given a keyword."
  (should-error (org-sql--kw-to-colname 1))
  (should-error (org-sql--kw-to-colname "1"))
  (should-error (org-sql--kw-to-colname 'a))
  (should-error (org-sql--kw-to-colname '())))

(ert-deftest org-sql/kw-to-colname-keyword ()
  "Should return error when given nil."
  (should (equal "yeah-boi" (org-sql--kw-to-colname :yeah-boi))))