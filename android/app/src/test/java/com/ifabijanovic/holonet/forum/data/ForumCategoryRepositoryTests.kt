package com.ifabijanovic.holonet.forum.data

import org.junit.Before
import org.junit.Test

/**
 * Created by Ivan Fabijanovic on 22/03/2017.
 */
class ForumCategoryRepositoryTests: ForumRepositoryTestsBase() {
    private var repo: ForumCategoryRepository? = null

    @Before
    override fun setUp() {
        super.setUp()
        this.repo = DefaultForumCategoryRepository(ForumParser(), this.service!!, this.settings)
    }

    @Test
    fun emptyHtml() {
        this.stubHtmlResource("forum-empty")

        val observer = this.repo!!.categories(this.language).test()
        observer.assertNoErrors()
        observer.assertNoValues()
    }
}