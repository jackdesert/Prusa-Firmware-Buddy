#include "DialogHandler.h"
#include "gui.h"
#include "DialogNONE.hpp"
#include "DialogLoadUnload.hpp"
#include "static_alocation_ptr.hpp"

//screens do not have headers, have to use extern
extern screen_t *pscreen_printing_serial;

class DialogHandler {
    static_unique_ptr<IDialog> ptr;
    std::aligned_union<0, /*DialogNONE,*/ DialogLoadUnload>::type all_dialogs;

public:
    DialogHandler()
    //: ptr(make_static_unique_ptr<DialogNONE>(&all_dialogs))
    {}

    void open(dialog_t dialog, uint8_t data);
    void close(dialog_t dialog);
    void change(dialog_t dialog, uint8_t phase, uint8_t progress_tot, uint8_t progress);
};

DialogHandler dlg_hndlr;

#include "window_dlg_change.h" //testcode
//static std::aligned_union<0, DialogNONE>::type all_dialogs;

void dialog_open_cb(dialog_t dialog, uint8_t data) {
    dlg_hndlr.open(dialog, data);
}

void dialog_close_cb(dialog_t dialog) {
    dlg_hndlr.close(dialog);
}

void dialog_change_cb(dialog_t dialog, uint8_t phase, uint8_t progress_tot, uint8_t progress) {
    dlg_hndlr.change(dialog, phase, progress_tot, progress);
}
//*****************************************************************************
//method definitions
void DialogHandler::open(dialog_t dialog, uint8_t data) {
    if (gui_get_nesting() > 1)
        return; //todo notify octoprint
    if (dialog == DLG_serial_printing) {
        screen_unloop(m876_blacklist, m876_blacklist_sz);

        if (screen_get_curr() != pscreen_printing_serial)
            screen_open(pscreen_printing_serial->id);
    }

    if (dialog == DLG_load_unload) {
        if (!ptr) {
            ptr = make_static_unique_ptr<DialogLoadUnload>(&all_dialogs, "SOME NAME");
        }
    }
    //gui_dlg_change(); //testcode
}

void DialogHandler::close(dialog_t dialog) {
    if (gui_get_nesting() > 1)
        return; //todo notify octoprint
    if (dialog == DLG_serial_printing) {
        if (screen_get_curr() == pscreen_printing_serial)
            screen_close();
    }
}

void DialogHandler::change(dialog_t dialog, uint8_t phase, uint8_t progress_tot, uint8_t progress) {
    switch (dialog) {
    }
}
