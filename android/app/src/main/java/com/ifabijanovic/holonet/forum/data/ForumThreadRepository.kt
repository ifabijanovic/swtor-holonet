package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import com.ifabijanovic.holonet.forum.model.ForumCategory
import com.ifabijanovic.holonet.forum.model.ForumMaintenanceException
import com.ifabijanovic.holonet.forum.model.ForumThread
import com.ifabijanovic.holonet.helper.StringHelper
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import org.jsoup.Jsoup
import org.jsoup.nodes.Element

/**
 * Created by Ivan Fabijanovic on 23/03/2017.
 */
interface ForumThreadRepository {
    fun threads(language: ForumLanguage, category: ForumCategory, page: Int): Observable<List<ForumThread>>
}

class DefaultForumThreadRepository(parser: ForumParser, service: ForumService, settings: Settings) : ForumRepositoryBase(parser, service, settings), ForumThreadRepository {
    override fun threads(language: ForumLanguage, category: ForumCategory, page: Int): Observable<List<ForumThread>> {
        val localizedSettings = this.localizedSettings(language)

        return this.service
                .category(localizedSettings.pathPrefix, category.id)
                .subscribeOn(Schedulers.io())
                .observeOn(Schedulers.computation())
                .map { html ->
                    val items = this.parse(html)
                    if (items.isEmpty() && this.isMaintenance(html)) {
                        throw ForumMaintenanceException()
                    }
                    return@map items
                }
    }

    private fun parse(html: String): List<ForumThread>{
        val items = mutableListOf<ForumThread>()

        Jsoup.parse(html)
                .select("table#threadslist tr")
                .mapIndexedNotNullTo(items) { index, node -> this.parseThread(node, index) }

        return items.toList()
    }

    private fun parseThread(element: Element, index: Int): ForumThread? {
        // Id & Title
        val titleElement = element.select(".threadTitle")?.first()
        val idString = this.parser.linkParameter(titleElement, this.settings.threadQueryParam)
        var id: Int?
        try {
            id = idString?.toInt()
        } catch (e: Exception) {
            id = null
        }
        val title = titleElement?.text()

        // Last post date
        val lastPostDate = element.select(".lastpostdate")?.first()?.text()

        // Author
        val author = element.select(".author")?.first()?.text()

        // Replies
        val replies = this.parser.integerContent(element.select(".resultReplies")?.first())

        // Views
        val views = this.parser.integerContent(element.select(".resultViews")?.first())

        // Has Bioware reply & sticky
        var hasBiowareReply = false
        var isSticky = false
        val imageElements = element.select(".threadLeft img.inlineimg")
        imageElements
                .mapNotNull { it.attr("src") }
                .forEach {
                    if (it == this.settings.devTrackerIconUrl) {
                        hasBiowareReply = true
                    } else if (it == this.settings.stickyIconUrl) {
                        isSticky = true
                    }
                }

        if (id == null) { return null }
        if (title == null) { return null }
        if (lastPostDate == null) { return null }
        if (author == null) { return null }
        if (replies == null) { return null }
        if (views == null) { return null }

        val finalTitle = StringHelper(title).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value
        val finalLastPostDate = StringHelper(lastPostDate).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value
        val finalAuthor = StringHelper(author).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value

        return ForumThread(id, finalTitle, finalLastPostDate, finalAuthor, replies, views, hasBiowareReply, isSticky, false, index)
    }
}
