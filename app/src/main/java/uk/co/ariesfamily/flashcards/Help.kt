package uk.co.ariesfamily.flashcards

import android.content.Intent
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.MenuItem
import kotlinx.android.synthetic.main.activity_help.*


class Help : AppCompatActivity() {

    private val savedTheme1 = "Theme1"

    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val themeName = pref.getInt(savedTheme1,0)

        //get saved setup
        when (themeName){
            1 -> setTheme(R.style.ActivityTheme_Primary_Base_Dark)
            2 -> setTheme(R.style.nightTheme)
            3 -> setTheme(R.style.whitTheme)
            else -> setTheme(R.style.AppTheme)
        }

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_help)

        //load URL string
        val webSettings = webview.settings
        webSettings.javaScriptEnabled = true
        webview.loadUrl(getString(R.string.webviewURL))
    }

    //onclick events for launching activities
    fun startMain(item: MenuItem) {
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }
    fun startSettings(item: MenuItem) {
        val intent = Intent(this, Settings::class.java).apply {  }
        startActivity(intent)
    }
    fun startHelp(item: MenuItem) {
        val intent = Intent(this, Help::class.java).apply {  }
        startActivity(intent)
    }
    //back button
    fun backButtonPress(view: android.view.View){
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }
}
