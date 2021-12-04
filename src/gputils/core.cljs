(ns gputils.core
  (:require
    [reagent.dom :as rd]
    [clojure.string :as str]
    [reagent.core :as reagent :refer [atom]]
    [cljs.pprint :as pp :refer [pprint]]
    [oops.core :refer [oget oset! ocall! ;; ocall oapply oapply!
                       oget+ #_oset!+]]
    [clojure.edn :as edn]
    )
  )


#_(def edn-readers {'mulife.core.rule-frame.RuleFrame map->RuleFrame
                  'mulife.core.rule-frame.Slave map->Slave
                  'mulife.rule-frame.RuleFrame map->RuleFrame
                  'mulife.rule-frame.Slave map->Slave})


(defn send-data
  "Creates a link, puts the current rule data in a blob, encodes that blob,
   and calls the click method on the link to send it to the user.  Essentally this
   is how we can have a nice download button instead of an actual link that the user
   needs to right-click on to download."
  [data-map]
  (let [rule-blob     (js/Blob. (seq (prn-str data-map)) (clj->js {:type "application/edn"}))
        document      (oget js/window "document")
        url           (oget js/window "URL")
        link          (ocall! document "createElement" "a")
        rule-blob-url (ocall! url "createObjectURL" rule-blob)]
    (-> link
        (oset! "target" "_blank")
        (oset! "href" rule-blob-url)
        (oset! "download" (:download-filename data-map))
        (ocall! "click"))))



(defn fetch-and-parse-uploaded-file!
      "Uses some basic JS DOM calls to get the uploaded data, then uses the
      'then' method of the promise that comes back to slurp and parse the
      actual data.  Finally, swaps the resulting map in to replace
      app-state in its entirety.  This essentially resets the entire app
      back to where it was when you saved the file you load."
      [edn-readers callback]
      (let [document            (oget js/window "document")
            selected-files      (ocall! document "getElementById" "uploaded-files")
            first-selected-file (oget+ selected-files "files" "0")]
           (println "UPLOADING FILES:" selected-files "," first-selected-file)
           (-> (ocall! first-selected-file "text")
               (.then (fn [fc]
                          (let [new-map (edn/read-string {:readers edn-readers} fc)]
                            (callback new-map)))))))


(defn upload-control
  "A control to upload your rules."
  [edn-readers callback]
  [:div {:class "upload fileUpload btn btn-primary col_12"}
   [:label {:for "upload-button"
            :class "col_6"} "Upload ruleset"]
   [:input {:id            "uploaded-files"
            :type          "file"
            :style {:font-size "8pt"}
            :class         "upload col_6"
            :placeholder   "rules.edn"
            :on-change     #(fetch-and-parse-uploaded-file! edn-readers callback)}]])




(defn download-control
      "A control to download your rules."
      [data-map on-change-fn]
      (let [help-text "Enter a filename for the ruleset you want to download."]
           [:div {:class "download-control col_12"}
            [:label {:for "description"} "Description"]
            [:textarea {:style         {:height        "auto"
                                        :margin-bottom "5px"
                                        :float         "right"}
                        :id            "description"
                        :rows          "4"
                        :class         "col_12"
                        :on-change     on-change-fn
                        :default-value (:description data-map)}
             (:description data-map)]
            [:br]
            [:label {:for "download-button"
                     ;:class "col_7"
                     } "Download ruleset"]
            [:button {:id       "download-button"
                      :type     "button"
                      :class    "small"
                      :on-click #(send-data data-map)}
             [:span {:class "fas fa-download"}]]
            [:input {:id            "download-filename"
                     :alt           help-text
                     :title         help-text
                     :style         {:float "right"}
                     :type          "text"
                     :class         "medium"
                     :placeholder   "rules.edn"
                     :on-change     on-change-fn
                     :default-value (:download-filename data-map)}]]))

(defn upload-control
      "A control to upload your rules."
      [edn-readers callback]
      [:div {:class "upload fileUpload btn btn-primary col_12"}
       [:label {:for "upload-button"
                :class "col_6"} "Upload ruleset"]
       [:input {:id            "uploaded-files"
                :type          "file"
                :style {:font-size "8pt"}
                :class         "upload col_6"
                :placeholder   "rules.edn"
                :on-change     #(fetch-and-parse-uploaded-file! edn-readers callback)}]])