package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.forum.model.ForumCategory
import org.junit.Before
import org.junit.Test
import org.junit.Assert.*

/**
 * Created by Ivan Fabijanovic on 23/03/2017.
 */
class ForumThreadRepositoryTests: ForumRepositoryTestsBase() {
    private var repo: ForumThreadRepository? = null
    private val testCategory = ForumCategory(17, null, "Test", null, null, null)

    @Before
    override fun setUp() {
        super.setUp()
        this.repo = DefaultForumThreadRepository(ForumParser(), this.service!!, this.settings)
    }

    @Test
    fun emptyHtml() {
        this.stubHtmlResource("forum-empty")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Valid() {
        this.stubHtmlResource("Thread/forum-thread-single-valid")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertEquals("Forum thread 5", items[0].title)
        assertEquals("Today 12:22 AM", items[0].lastPostDate)
        assertEquals("Author name 5", items[0].author)
        assertEquals(5, items[0].replies)
        assertEquals(7, items[0].views)
        assertTrue(items[0].hasBiowareReply)
        assertTrue(items[0].isSticky)
    }

    @Test
    fun singleItem_NotDev() {
        this.stubHtmlResource("Thread/forum-thread-single-valid-not-dev")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertFalse(items[0].hasBiowareReply)
    }

    @Test
    fun singleItem_NotSticky() {
        this.stubHtmlResource("Thread/forum-thread-single-valid-not-sticky")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertFalse(items[0].isSticky)
    }

    @Test
    fun singleItem_Invalid_Id() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-id")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Invalid_Title() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-title")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Invalid_LastPostDate() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-last-post-date")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Invalid_Author() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-author")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Invalid_Replies() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-replies")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Invalid_Views() {
        this.stubHtmlResource("Thread/forum-thread-single-invalid-views")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun multipleItems_Valid() {
        this.stubHtmlResource("Thread/forum-thread-multiple-valid")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(3, items.size)

        if (items.size != 3) { return }

        assertEquals(5, items[0].id)
        assertEquals("Forum thread 5", items[0].title)
        assertEquals("Today 12:22 AM", items[0].lastPostDate)
        assertEquals("Author name 5", items[0].author)
        assertEquals(5, items[0].replies)
        assertEquals(7, items[0].views)
        assertTrue(items[0].hasBiowareReply)
        assertTrue(items[0].isSticky)

        assertEquals(6, items[1].id)
        assertEquals("Forum thread 6", items[1].title)
        assertEquals("Today 09:22 AM", items[1].lastPostDate)
        assertEquals("Author name 6", items[1].author)
        assertEquals(6, items[1].replies)
        assertEquals(8, items[1].views)
        assertTrue(items[1].hasBiowareReply)
        assertFalse(items[1].isSticky)

        assertEquals(7, items[2].id)
        assertEquals("Forum thread 7", items[2].title)
        assertEquals("Today 11:22 AM", items[2].lastPostDate)
        assertEquals("Author name 7", items[2].author)
        assertEquals(7, items[2].replies)
        assertEquals(9, items[2].views)
        assertFalse(items[2].hasBiowareReply)
        assertTrue(items[2].isSticky)
    }

    @Test
    fun multipleItems_InvalidId() {
        this.stubHtmlResource("Thread/forum-thread-multiple-invalid-id")

        val items = this.repo!!.threads(this.language, this.testCategory, 1).blockingFirst()
        assertNotNull(items)
        assertEquals(2, items.size)

        if (items.size != 2) { return }

        assertEquals(6, items[0].id)
        assertEquals(7, items[1].id)
    }
}