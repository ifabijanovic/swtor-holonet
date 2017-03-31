package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.forum.model.ForumThread
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

/**
 * Created by Ivan Fabijanovic on 31/03/2017.
 */
class ForumPostRepositoryTests: ForumRepositoryTestsBase() {
    private var repo: ForumPostRepository? = null
    private val testThread = ForumThread(5, "Test", "Today", "Test user", 5, 7)

    @Before
    override fun setUp() {
        super.setUp()
        this.repo = DefaultForumPostRepository(ForumParser(), this.service!!, this.settings)
    }

    @Test
    fun emptyHtml() {
        this.stubHtmlResource("forum-empty")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Valid() {
        this.stubHtmlResource("Post/forum-post-single-valid")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertEquals("http://www.holonet.test/avatar.png", items[0].avatarUrl)
        assertEquals("User name 5", items[0].username)
        assertEquals("1.1.2014, 08:22 AM", items[0].date)
        assertEquals(1, items[0].postNumber)
        assertTrue(items[0].isBiowarePost)
        assertTrue(items[0].text.count() > 0)
        assertTrue(items[0].signature!!.count() > 0)
    }

    @Test
    fun singleItem_NotDev() {
        this.stubHtmlResource("Post/forum-post-single-valid-not-dev")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertFalse(items[0].isBiowarePost)
    }

    @Test
    fun singleItem_InvalidId() {
        this.stubHtmlResource("Post/forum-post-single-invalid-id")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_InvalidUsername() {
        this.stubHtmlResource("Post/forum-post-single-invalid-username")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_InvalidDate() {
        this.stubHtmlResource("Post/forum-post-single-invalid-date")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_MissingOptionals() {
        this.stubHtmlResource("Post/forum-post-single-missing-optionals")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertNull(items[0].avatarUrl)
        assertNull(items[0].postNumber)
    }

    @Test
    fun multipleItems_Valid() {
        this.stubHtmlResource("Post/forum-post-multiple-valid")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(3, items.size)

        if (items.size != 3) { return }

        assertEquals(5, items[0].id)
        assertEquals("http://www.holonet.test/avatar.png", items[0].avatarUrl)
        assertEquals("User name 5", items[0].username)
        assertEquals("1.1.2014, 08:22 AM", items[0].date)
        assertEquals(1, items[0].postNumber)
        assertTrue(items[0].isBiowarePost)
        assertTrue(items[0].text.count() > 0)
        assertTrue(items[0].signature!!.count() > 0)

        assertEquals(6, items[1].id)
        assertEquals("http://www.holonet.test/avatar.png", items[1].avatarUrl)
        assertEquals("User name 6", items[1].username)
        assertEquals("2.2.2014, 09:22 AM", items[1].date)
        assertEquals(2, items[1].postNumber)
        assertFalse(items[1].isBiowarePost)
        assertTrue(items[1].text.count() > 0)
        assertTrue(items[1].signature!!.count() > 0)

        assertEquals(7, items[2].id)
        assertEquals("http://www.holonet.test/avatar.png", items[2].avatarUrl)
        assertEquals("User name 7", items[2].username)
        assertEquals("3.3.2014, 10:22 AM", items[2].date)
        assertEquals(3, items[2].postNumber)
        assertTrue(items[2].isBiowarePost)
        assertTrue(items[2].text.count() > 0)
        assertTrue(items[2].signature!!.count() > 0)
    }

    @Test
    fun multipleItems_InvalidId() {
        this.stubHtmlResource("Post/forum-post-multiple-invalid-id")

        val items = this.repo!!.posts(this.language, this.testThread, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(2, items.size)

        if (items.size != 2) { return }

        assertEquals(5, items[0].id)
        assertEquals(7, items[1].id)
    }
}