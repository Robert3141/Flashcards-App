package uk.co.ariesfamily.flashcards

import android.content.Intent
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.v7.app.AppCompatActivity
import android.view.MenuItem
import android.widget.AdapterView

import kotlinx.android.synthetic.main.activity_settings.*

class Settings : AppCompatActivity(), AdapterView.OnItemSelectedListener {

    private val savedTheme1 = "Theme1"
    private val savedFlashcardFlipper = "flashcardFlipper"
    private val savedFlashcardOrder = "flashcardOrder"
    private var userIsInteracting = false

    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val themeName = pref.getInt(savedTheme1,0)
        val flashcardFlipper = pref.getBoolean(savedFlashcardFlipper, false)
        val flashcardOrder = pref.getInt(savedFlashcardOrder,0)

        //get saved setup
        when (themeName){
            1 -> setTheme(R.style.ActivityTheme_Primary_Base_Dark)
            2 -> setTheme(R.style.nightTheme)
            3 -> setTheme(R.style.whitTheme)
            else -> setTheme(R.style.AppTheme)
        }

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)

        //setup spinner click listener
        spinnerTheme.onItemSelectedListener = this
        spinnerOrder.onItemSelectedListener = this


        //set the settings
        //theme spinner
        spinnerTheme.setSelection(themeName)
        //flip cards switch
        switchFlipCards.isChecked = flashcardFlipper
        //order spinner
        spinnerOrder.setSelection(flashcardOrder)
    }

    override fun onItemSelected(parent: AdapterView<*>, view: android.view.View?, pos: Int, id: Long) {
        //solve problems
        if (userIsInteracting) {
            updateSettings()
        }
    }

    override fun onNothingSelected(parent: AdapterView<*>) {
        // Another interface callback
    }

    override fun onUserInteraction() {
        super.onUserInteraction()
        userIsInteracting = true
    }

    //onclick events for launching activities
    fun startMain(@Suppress("UNUSED_PARAMETER")item: MenuItem) {
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }
    fun startNewCards(@Suppress("UNUSED_PARAMETER")item: MenuItem) {
        val intent = Intent(this, CreateCards::class.java).apply {  }
        startActivity(intent)
    }
    fun startSettings(@Suppress("UNUSED_PARAMETER")item: MenuItem) {
        val intent = Intent(this, Settings::class.java).apply {  }
        startActivity(intent)
    }
    fun startHelp(@Suppress("UNUSED_PARAMETER")item: MenuItem) {
        val intent = Intent(this, Help::class.java).apply {  }
        startActivity(intent)
    }
    //back button
    fun backButtonPress(@Suppress("UNUSED_PARAMETER")view: android.view.View){
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }

    fun itemClicked(@Suppress("UNUSED_PARAMETER")view: android.view.View) {
        updateSettings()
    }

    private fun updateSettings() {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val editor = pref.edit()
        val selectedTheme = spinnerTheme.selectedItemPosition
        val selectedFlipper = switchFlipCards.isChecked
        val flashcardOrder = spinnerOrder.selectedItemPosition

        //save values
        editor.putInt(savedTheme1,selectedTheme)
        editor.putBoolean(savedFlashcardFlipper,selectedFlipper)
        editor.putInt(savedFlashcardOrder,flashcardOrder)

        //push settings
        editor.commit()

        //reload activity
        recreate()
    }

}
