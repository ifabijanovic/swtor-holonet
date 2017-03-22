package com.ifabijanovic.holonet.forum.data

import org.junit.Before
import org.junit.Test
import org.junit.Assert.*

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

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_Valid() {
        this.stubHtmlResource("Category/forum-category-single-valid")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertEquals("http://www.holonet.test/category_icon5.png", items[0].iconUrl)
        assertEquals("Forum category 5", items[0].title)
        assertEquals("Description 5", items[0].description)
        assertEquals("5 Total Threads, 12 Total Posts", items[0].stats)
        assertEquals("Last Post: Thread 17", items[0].lastPost)
    }

    @Test
    fun singleItem_InvalidId() {
        this.stubHtmlResource("Category/forum-category-single-invalid-id")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(0, items.size)
    }

    @Test
    fun singleItem_MissingOptionals() {
        this.stubHtmlResource("Category/forum-category-single-missing-optionals")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(1, items.size)

        if (items.size != 1) { return }

        assertEquals(5, items[0].id)
        assertNull(items[0].iconUrl)
        assertEquals("Forum category 5", items[0].title)
        assertNull(items[0].description)
        assertNull(items[0].stats)
        assertNull(items[0].lastPost)
    }

    @Test
    fun multipleItems_Valid() {
        this.stubHtmlResource("Category/forum-category-multiple-valid")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(3, items.size)

        if (items.size != 3) { return }

        assertEquals(5, items[0].id)
        assertEquals("http://www.holonet.test/category_icon5.png", items[0].iconUrl)
        assertEquals("Forum category 5", items[0].title)
        assertEquals("Description 5", items[0].description)
        assertEquals("5 Total Threads, 12 Total Posts", items[0].stats)
        assertEquals("Last Post: Thread 17", items[0].lastPost)

        assertEquals(6, items[1].id)
        assertEquals("http://www.holonet.test/category_icon6.png", items[1].iconUrl)
        assertEquals("Forum category 6", items[1].title)
        assertEquals("Description 6", items[1].description)
        assertEquals("6 Total Threads, 13 Total Posts", items[1].stats)
        assertEquals("Last Post: Thread 18", items[1].lastPost)

        assertEquals(7, items[2].id)
        assertEquals("http://www.holonet.test/category_icon7.png", items[2].iconUrl)
        assertEquals("Forum category 7", items[2].title)
        assertEquals("Description 7", items[2].description)
        assertEquals("7 Total Threads, 14 Total Posts", items[2].stats)
        assertEquals("Last Post: Thread 19", items[2].lastPost)
    }

    @Test
    fun multipleItems_InvalidId() {
        this.stubHtmlResource("Category/forum-category-multiple-missing-id")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(2, items.size)

        if (items.size != 2) { return }

        assertEquals(5, items[0].id)
        assertEquals(7, items[1].id)
    }

    @Test
    fun multipleItems_MissingOptionals() {
        this.stubHtmlResource("Category/forum-category-multiple-missing-optionals")

        val items = this.repo!!.categories(this.language).blockingFirst()
        assertNotNull(items)
        assertEquals(3, items.size)

        if (items.size != 3) { return }

        assertEquals(5, items[0].id)
        assertNull(items[0].iconUrl)
        assertEquals("Forum category 5", items[0].title)
        assertEquals("Description 5", items[0].description)
        assertEquals("5 Total Threads, 12 Total Posts", items[0].stats)
        assertEquals("Last Post: Thread 17", items[0].lastPost)

        assertEquals(6, items[1].id)
        assertEquals("http://www.holonet.test/category_icon6.png", items[1].iconUrl)
        assertEquals("Forum category 6", items[1].title)
        assertNull(items[1].description)
        assertEquals("6 Total Threads, 13 Total Posts", items[1].stats)
        assertEquals("Last Post: Thread 18", items[1].lastPost)

        assertEquals(7, items[2].id)
        assertEquals("http://www.holonet.test/category_icon7.png", items[2].iconUrl)
        assertEquals("Forum category 7", items[2].title)
        assertEquals("Description 7", items[2].description)
        assertNull(items[2].stats)
        assertNull(items[2].lastPost)
    }
}
