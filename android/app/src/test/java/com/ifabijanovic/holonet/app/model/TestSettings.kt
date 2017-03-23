package com.ifabijanovic.holonet.app.model

/**
 * Created by Ivan Fabijanovic on 22/03/2017.
 */
class TestSettings: Settings {
    override val appEmail: String = "holonet.swtor@gmail.com"
    override val categoryQueryParam: String = "category"
    override val threadQueryParam: String = "thread"
    override val baseForumUrl: String = "http://www.swtor.com"
    override val devTrackerIconUrl: String = "http://www.holonet.test/devIcon.png"
    override val devAvatarUrl: String = "http://www.holonet.test/devAvatar.png"
    override val stickyIconUrl: String = "http://www.holonet.test/stickyIcon.png"
    override val dulfyNetUrl: String = "http://dulfy.test"
    override val requestTimeout: Int = 10000
    override val localized: Map<String, LocalizedSettings>

    init {
        val en = LocalizedSettings("", 100, 1000)
        val fr = LocalizedSettings("fr", 200, 2000)
        val de = LocalizedSettings("de", 300, 3000)
        this.localized = hashMapOf("en" to en, "fr" to fr, "de" to de)
    }
}
