package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import io.reactivex.Observable
import org.junit.Before
import org.mockito.Mockito.*
import org.junit.Assert.*

/**
 * Created by Ivan Fabijanovic on 21/03/2017.
 */
open class ForumRepositoryTestsBase {
    protected val settings = Settings()
    protected val language = ForumLanguage.english
    protected var service: ForumService? = null

    @Before
    open fun setUp() {
        this.service = mock(ForumService::class.java)
    }

    protected fun stubHtmlResource(name: String) {
        assertNotNull(this.service)
        val stream = this.javaClass.getResourceAsStream("/forum/$name.html")
        assertNotNull(stream)
        val html = stream.bufferedReader().use { it.readText() }

        reset(this.service!!)
        `when`(this.service!!.category(anyString(), anyInt())).thenReturn(Observable.just(html))
        `when`(this.service!!.thread(anyString(), anyInt(), anyInt())).thenReturn(Observable.just(html))
        `when`(this.service!!.devTracker(anyString(), anyInt())).thenReturn(Observable.just(html))
    }
}