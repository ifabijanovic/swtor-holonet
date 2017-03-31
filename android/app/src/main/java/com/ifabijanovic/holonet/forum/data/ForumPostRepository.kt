package com.ifabijanovic.holonet.forum.data

import com.ifabijanovic.holonet.app.model.Settings
import com.ifabijanovic.holonet.forum.language.ForumLanguage
import com.ifabijanovic.holonet.forum.model.ForumMaintenanceException
import com.ifabijanovic.holonet.forum.model.ForumPost
import com.ifabijanovic.holonet.forum.model.ForumThread
import com.ifabijanovic.holonet.helper.StringHelper
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers
import org.jsoup.Jsoup
import org.jsoup.nodes.Element

/**
 * Created by Ivan Fabijanovic on 31/03/2017.
 */

interface ForumPostRepository {
    fun posts(language: ForumLanguage, thread: ForumThread, page: Int): Observable<List<ForumPost>>
}

class DefaultForumPostRepository(parser: ForumParser, service: ForumService, settings: Settings) : ForumRepositoryBase(parser, service, settings), ForumPostRepository {
    override fun posts(language: ForumLanguage, thread: ForumThread, page: Int): Observable<List<ForumPost>> {
        val localizedService = this.localizedSettings(language)

        val request: Observable<String>
        if (thread.isDevTracker) {
            request = this.service.devTracker(localizedService.pathPrefix, page)
        } else {
            request = this.service.thread(localizedService.pathPrefix, thread.id, page)
        }

        return request
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

    private fun parse(html: String): List<ForumPost> {
        val items = mutableListOf<ForumPost>()

        Jsoup.parse(html)
                .select("#posts table.threadPost")
                .mapNotNullTo(items) { this.parsePost(it) }

        return items.toList()
    }

    private fun parsePost(element: Element): ForumPost? {
        // Id
        val idString = this.parser.linkParameter(element.select(".post .threadDate a")?.first(), this.settings.postQueryParam)
        var id: Int?
        try {
            id = idString?.toInt()
        } catch (e: Exception) {
            id = null
        }

        // Avatar url
        var avatarUrl: String? = null
        val avatarElement = element.select(".avatar img")?.first()
        if (avatarElement != null) {
            avatarUrl = avatarElement.attr("src")
        }

        // Username
        val username = element.select(".avatar > .resultCategory > a")?.first()?.text()

        // Date & Post number
        val dateElement = element.select(".post .threadDate")?.last()
        val date = this.parser.postDate(dateElement)
        val postNumber = this.parser.postNumber(dateElement)

        // Is Bioware post
        val imageElements = element.select(".post img.inlineimg")
        var isBiowarePost = imageElements
                .mapNotNull { it.attr("src") }
                .any { it == this.settings.devTrackerIconUrl }

        // Additional check for Dev Avatar (used on Dev Tracker)
        if (!isBiowarePost) {
            isBiowarePost = avatarUrl != null && avatarUrl == this.settings.devAvatarUrl
        }

        // Text
        val text = element.select(".post .forumPadding > .resultText")?.text() // Not parsed for now

        // Signature
        val lastPostRow = element.select(".post tr")?.last()
        val signature = lastPostRow?.select(".resultText")?.text()

        if (id == null) { return null }
        if (username == null) { return null }
        if (date == null) { return null }
        if (text == null) { return null }

        val finalUsername = StringHelper(username).stripNewLinesAndTabs().trimSpaces().collapseMultipleSpaces().value

        return ForumPost(id, avatarUrl, finalUsername, date, postNumber, isBiowarePost, text, signature)
    }
}
