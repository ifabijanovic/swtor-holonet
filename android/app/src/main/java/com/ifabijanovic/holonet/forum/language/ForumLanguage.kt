package com.ifabijanovic.holonet.forum.language

/**
 * Created by feb on 19/03/2017.
 */
enum class ForumLanguage(val languageCode: String) {
    english("en"),
    french("fr"),
    german("de");

    val next: String get() {
        when (this) {
            english -> return "Next"
            french -> return "Suivante"
            german -> return "Nächste"
        }
    }
}
