package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.LocalizedSettings
import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.scalars.ScalarsConverterFactory

/**
 * Created by feb on 19/03/2017.
 */
abstract class ForumRepositoryBase(protected val parser: ForumParser, protected val settings: Settings) {
    protected val service: ForumService

    init {
        this.service = Retrofit.Builder()
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(ScalarsConverterFactory.create())
                .baseUrl(this.settings.baseForumUrl)
                .build()
                .create(ForumService::class.java)
    }

    protected fun localizedSettings(language: ForumLanguage): LocalizedSettings {
        val localizedSettings = settings.localized[language.languageCode]
        assert(localizedSettings != null)
        return localizedSettings!!
    }
}