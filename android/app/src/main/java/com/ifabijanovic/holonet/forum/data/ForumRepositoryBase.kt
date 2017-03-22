package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.LocalizedSettings
import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory

/**
 * Created by feb on 19/03/2017.
 */
abstract class ForumRepositoryBase(
        protected val parser: ForumParser,
        protected val service: ForumService,
        protected val settings: Settings
) {
    protected fun localizedSettings(language: ForumLanguage): LocalizedSettings {
        val localizedSettings = settings.localized[language.languageCode]
        assert(localizedSettings != null)
        return localizedSettings!!
    }

    protected fun isMaintenance(html: String): Boolean {
        val document = Jsoup.parse(html)
        val errorNodes = document.select("#mainContent > #errorPage #errorBody p")

        if (errorNodes == null || errorNodes.isEmpty()) { return false }
        // TODO implement based on language
        return errorNodes.first().text().contains("scheduled maintenance", true)
    }
}
