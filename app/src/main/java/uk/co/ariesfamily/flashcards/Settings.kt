package uk.co.ariesfamily.flashcards

import android.content.Intent
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.design.widget.Snackbar
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem
import android.widget.Adapter
import android.widget.AdapterView

import kotlinx.android.synthetic.main.activity_settings.*

class Settings : AppCompatActivity(), AdapterView.OnItemSelectedListener {

    private val savedTheme1 = "Theme1"
    private val savedFlashcardFlipper = "flashcardFlipper"
    private var userIsInteracting = false

    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val themeName = pref.getInt(savedTheme1,0)
        val flashcardFlipper = pref.getBoolean(savedFlashcardFlipper, false)

        //get saved setup
        when (themeName){
            1 -> setTheme(R.style.ActivityTheme_Primary_Base_Dark)
            2 -> setTheme(R.style.nightTheme)
            else -> setTheme(R.style.AppTheme)
        }

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)

        //setup toolbar
        setSupportActionBar(toolbar)
        toolbar.navigationIcon = getDrawable(R.drawable.baseline_arrow_back_24)
        toolbar.setNavigationOnClickListener(
            fun (view: android.view.View){
                val intent = Intent(this, MainActivity::class.java).apply {  }
                startActivity(intent)
            }
        )

        //setup spinner click listener
        spinnerTheme.onItemSelectedListener = this


        //set the settings
        //spinner
        when (themeName){
            1 -> spinnerTheme.setSelection(1)
            2 -> spinnerTheme.setSelection(2)
            else -> spinnerTheme.setSelection(0)
        }
        //switch
        switchFlipCards.isChecked = flashcardFlipper
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

    fun itemClicked(view: android.view.View) {
        updateSettings()
    }

    private fun updateSettings() {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        var editor = pref.edit()
        val selectedTheme = spinnerTheme.selectedItemPosition
        val selectedFlipper = switchFlipCards.isChecked

        //save values
        editor.putInt(savedTheme1,selectedTheme)
        editor.putBoolean(savedFlashcardFlipper,selectedFlipper)

        //push settings
        editor.commit()

        //reload activity
        recreate()
    }

}
