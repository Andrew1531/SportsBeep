package com.sportsbeep.app.ui.game.buildteam

import android.app.ProgressDialog
import android.content.Intent
import android.os.AsyncTask
import android.os.Bundle
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.metova.slim.annotation.Extra
import com.sportsbeep.app.R
import com.sportsbeep.app.event.LeaguePickEvent
import com.sportsbeep.app.event.PlayersEvent
import com.sportsbeep.app.model.Result
import com.sportsbeep.app.model.game.Game
import com.sportsbeep.app.model.game.GamePosition
import com.sportsbeep.app.model.player.Player
import com.sportsbeep.app.model.team.Team
import com.sportsbeep.app.model.ticket.IncompleteTicket
import com.sportsbeep.app.model.ticket.TicketPlayer
import com.sportsbeep.app.model.ticket.TicketPositions
import com.sportsbeep.app.model.ticket.TicketSquad
import com.sportsbeep.app.network.params.ticket.LeaguePickTicketParams
import com.sportsbeep.app.network.params.ticket.TicketParams
import com.sportsbeep.app.network.params.ticket.UpdateTicketParams
import com.sportsbeep.app.storage.PlayerDaoHelper
import com.sportsbeep.app.storage.TeamDaoHelper
import com.sportsbeep.app.task.DeleteIncompleteTicketTask
import com.sportsbeep.app.task.SaveIncompleteTicketTask
import com.sportsbeep.app.task.network.NetworkAsyncTask
import com.sportsbeep.app.ui.base.BaseNavigationActivity
import com.sportsbeep.app.ui.contest.ContestActivity
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity
import com.sportsbeep.app.ui.game.pool.PickPoolActivity
import com.sportsbeep.app.ui.game.pool.SaveContestDialogFragment
import com.sportsbeep.app.ui.game.stats.PlayerStatsActivity
import com.sportsbeep.app.ui.game.stats.TeamStatsActivity
import com.squareup.otto.Produce
import java.util.concurrent.Executor
import javax.inject.Inject

class BuildTeamActivity : BaseNavigationActivity(),
    BuildTeamFragment.BuildTeamCallback,
    PickPlayerFragment.PickPlayerCallback,
    LeaguePickFragment.LeaguePickCallback,
    PickSquadFragment.PickSquadCallback {

    companion object {
        const val EXTRA_GAME = "game"
        const val EXTRA_INCOMPLETE_TICKET = "incomplete_ticket"
        const val EXTRA_TICKET_ID = "ticket_id"
        private const val TAG_BUILD_TEAM_FRAGMENT = "build_team_fragment"
        private const val TAG_SAVE_CONTEST = "save_contest"
    }

    @Extra(key = EXTRA_GAME)
    lateinit var game: Game

    @Extra(key = EXTRA_INCOMPLETE_TICKET, optional = true)
    var ticket: IncompleteTicket? = null

    @Extra(key = EXTRA_TICKET_ID, optional = true)
    var ticketId: Long = -1

    @Inject
    lateinit var playerDaoHelper: PlayerDaoHelper

    @Inject
    lateinit var teamDaoHelper: TeamDaoHelper

    var leaguePickGames: List<Game>? = null
    lateinit var buildTeamFragment: BuildTeamFragment
    var activeGamePosition: GamePosition? = null
    var carouselPositionStart: GamePosition? = null
    var showPositionCarousel = true

    private var playersTask: PlayersTask? = null
    private var leaguePickGamesTask: LeaguePickGamesTask? = null
    private var downloadTicketTask: DownloadTicketPlayersTask? = null
    private var updateTicketTask: UpdateTicketTask? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showPositionCarousel = ticket == null && !isInEditTicketMode()

        if (ticket == null) {
            ticket = IncompleteTicket().apply {
                setGame(game)
            }
        }

        if (savedInstanceState == null) {
            buildTeamFragment = BuildTeamFragment.newInstance(game, isInEditTicketMode()).apply {
                retainInstance = true
            }

            supportFragmentManager.beginTransaction()
                .add(R.id.content, buildTeamFragment, TAG_BUILD_TEAM_FRAGMENT)
                .commit()
        } else {
            buildTeamFragment = supportFragmentManager
                .findFragmentByTag(TAG_BUILD_TEAM_FRAGMENT) as BuildTeamFragment

            ticket = savedInstanceState.getParcelable(EXTRA_INCOMPLETE_TICKET)
            ticket?.positionMap?.forEach { (gamePosition, obj) ->
                when (obj) {
                    is Player -> buildTeamFragment.setPosition(gamePosition, obj)
                    is Team -> buildTeamFragment.setPosition(gamePosition, obj)
                }
            }
        }

        val executor: Executor = if (isInEditTicketMode()) {
            AsyncTask.SERIAL_EXECUTOR
        } else {
            AsyncTask.THREAD_POOL_EXECUTOR
        }

        playersTask = PlayersTask().apply {
            executeOnExecutor(executor)
        }

        if (sport.hasLeaguePick()) {
            leaguePickGamesTask = LeaguePickGamesTask().apply {
                executeOnExecutor(executor)
            }
        }

        if (isInEditTicketMode()) {
            ticket?.leaguePickTeam?.let { leaguePickTeam ->
                if (sport.hasLeaguePick()) {
                    val team = teamDaoHelper.getTeam(leaguePickTeam)
                    ticket?.leaguePickTeam = team
                }
            }

            downloadTicketTask = DownloadTicketPlayersTask().apply {
                executeOnExecutor(executor, ticketId)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        bus.register(this)
    }

    override fun onPause() {
        super.onPause()
        bus.unregister(this)
    }

    override fun onDestroy() {
        playersTask?.cancel(true)
        leaguePickGamesTask?.cancel(true)
        downloadTicketTask?.cancel(true)
        updateTicketTask?.cancel(true)
        super.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putParcelable(EXTRA_INCOMPLETE_TICKET, ticket)
    }

    override fun onBackPressed() {
        val fragment = supportFragmentManager.findFragmentById(R.id.content)
        if (fragment != buildTeamFragment) {
            showBuildTeamFragment()
        } else {
            val currentTicket = ticket
            if (currentTicket != null && 
                (!currentTicket.positionMap.isEmpty() || currentTicket.leaguePickTeam != null)) {
                showSaveContestDialog()
            } else {
                super.onBackPressed()
            }
        }
    }

    fun showSaveContestDialog() {
        val fragment = SaveContestDialogFragment.newInstance().apply {
            isCancelable = false
            setSaveContestClickListener(object : SaveContestDialogFragment.SaveContestClickListener {
                override fun onContinueClicked() {
                    // no-op
                }

                override fun onSaveClicked() {
                    if (isInEditTicketMode()) {
                        updateTicket()
                    } else {
                        ticket?.let { SaveIncompleteTicketTask().execute(it) }
                        showPickGameScreen()
                    }
                }

                override fun onCancelClicked() {
                    if (isInEditTicketMode()) {
                        showMyContestsScreen()
                    } else {
                        ticket?.let { currentTicket ->
                            if (currentTicket.id != 0L) {
                                DeleteIncompleteTicketTask().execute(currentTicket)
                            }
                        }
                        showPickGameScreen()
                    }
                }
            })
        }
        fragment.show(supportFragmentManager, TAG_SAVE_CONTEST)
    }

    private fun updateTicket() {
        val players = mutableListOf<TicketParams.TicketPositionParam>()
        val squads = mutableListOf<TicketParams.TicketPositionParam>()

        ticket?.positionMap?.forEach { (gamePosition, obj) ->
            when (obj) {
                is Player -> {
                    val playerParam = TicketParams.TicketPositionParam(
                        obj.id,
                        gamePosition.positionGroupTitleResName
                    )
                    players.add(playerParam)
                }
                is Team -> {
                    val squadParam = TicketParams.TicketPositionParam(
                        obj.id,
                        gamePosition.positionGroupTitleResName
                    )
                    squads.add(squadParam)
                }
            }
        }

        val ticketParams = ticket?.let { currentTicket ->
            if (currentTicket.leaguePickTeam != null && currentTicket.leaguePickGame != null) {
                val leaguePickGameId = currentTicket.leaguePickGame!!.id
                val leaguePickTeamId = currentTicket.leaguePickTeam!!.id
                LeaguePickTicketParams(players, squads, leaguePickGameId, leaguePickTeamId)
            } else {
                TicketParams(players, squads)
            }
        }

        ticketParams?.let {
            updateTicketTask = UpdateTicketTask().apply {
                execute(UpdateTicketParams(it))
            }
        }
    }

    private fun showPickGameScreen() {
        val intent = Intent(this, PickGameActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(intent)
    }

    private fun showMyContestsScreen() {
        val intent = Intent(this, ContestActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        startActivity(intent)
    }

    override fun onBuildTeamFragmentViewCreated() {
        ticket?.let { currentTicket ->
            buildTeamFragment.setPositionMap(currentTicket.positionMap)
            buildTeamFragment.setPosition(GamePosition.LEAGUE_PICK, currentTicket.leaguePickTeam)
        }
        checkRosterFull()
    }

    override fun onPositionClicked(gamePosition: GamePosition) {
        showGamePositionFragment(gamePosition)
    }

    override fun onSubmitTeam() {
        if (isInEditTicketMode()) {
            updateTicket()
        } else {
            val intent = Intent(this, PickPoolActivity::class.java).apply {
                putExtra(PickPoolActivity.EXTRA_TICKET, ticket)
            }
            startActivity(intent)
        }
    }

    private fun isInEditTicketMode(): Boolean = ticketId != -1L

    private fun checkRosterFull() {
        // Implementation needed
    }

    private fun showBuildTeamFragment() {
        // Implementation needed
    }

    private fun showGamePositionFragment(gamePosition: GamePosition) {
        // Implementation needed
    }

    // AsyncTask implementations would need to be converted to Coroutines
    // for modern Android development
    private inner class PlayersTask : AsyncTask<Void, Void, Result<List<Player>>>() {
        override fun doInBackground(vararg params: Void?): Result<List<Player>>? {
            // Load players from database/network
            return null
        }

        override fun onPostExecute(result: Result<List<Player>>?) {
            // Update UI with loaded players
        }
    }

    private inner class LeaguePickGamesTask : AsyncTask<Void, Void, Result<List<Game>>>() {
        override fun doInBackground(vararg params: Void?): Result<List<Game>>? {
            // Load league pick games
            return null
        }

        override fun onPostExecute(result: Result<List<Game>>?) {
            // Update UI
        }
    }

    private inner class DownloadTicketPlayersTask : AsyncTask<Long, Void, Result<TicketPositions>>() {
        override fun doInBackground(vararg params: Long?): Result<TicketPositions>? {
            // Download ticket players
            return null
        }

        override fun onPostExecute(result: Result<TicketPositions>?) {
            // Update UI
        }
    }

    private inner class UpdateTicketTask : NetworkAsyncTask<UpdateTicketParams, Void, Result<Void>>() {
        override fun doInBackground(vararg params: UpdateTicketParams?): Result<Void>? {
            // Update ticket on server
            return null
        }

        override fun onPostExecute(result: Result<Void>?) {
            // Handle result
        }
    }
}
