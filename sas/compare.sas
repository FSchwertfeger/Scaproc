%include "E:/TS/Parallel_prod_Frank/sas/init/cleanup.sas";
%include "E:/TS/Parallel_prod_Frank/sas/init/init.sas";

%include "&env_macro./prepare_log.sas";
%prepare_log;

x e:;
x cd\ts\parallel_prod_frank;
%include "E:\TS\Parallel_prod_Frank\Autoexec.sas";

options source source2 noerrorabend;

%include "&env_macro./finish.sas";
%include "&env_macro./compare_tables.sas";
%include "&env_macro./shorten_compare.sas";


* Vergleich der DYN_0 aus der Produktion mit der Nachberechnung;
%compare_tables(base=PROD390.dyn_0,
                compare=PCR390.dyn_0,
                drop=ID damarge ARESt_Marge MargenID,
                outname=dyn_0,
                id=ErweiterteVertragID DT_GAD DT_Refi darlart KredproX);
%shorten_compare(compare, dyn_0, keep=ErweiterteVertragID DT_GAD DT_Refi darlart KredproX);

* Vergleich der AZVorgabe aus Produktion mit der Nachberechnung;
%compare_tables(base=prod465.azvorgabe,
                compare=pcr465.azvorgabe,
                drop=ID DNNummer,
                outname=azvorgabe,
                id=erweitertevertragid profitcenter);
%shorten_compare(compare, azvorgabe, keep=erweitertevertragid profitcenter);



* Vergleich der PCR390.DYN_0 aus der Nachberechnung in GKS-265 mit der Nachberechnung in dieser Umgebung;
* Gleich;
libname g_390 "E:\TS\GKS-265\Daten\PCR\PCR390";
%compare_tables(base=g_390.dyn_0,
                compare=PCR390.dyn_0,
                drop=ID damarge ARESt_Marge MargenID,
                outname=gks265_dyn_0,
                id=ErweiterteVertragID DT_GAD DT_Refi darlart KredproX);

* Vergleich der PCR392.PCR_CF aus der Nachberechnung in GKS-265 mit der Nachberechnung in dieser Umgebung;
* Gleich;
libname g_392 "E:\TS\GKS-265\Daten\PCR\PCR392";
%compare_tables(base=g_392.pcr_cf,
                compare=PCR392.pcr_cf,
                drop=,
                outname=gks265_pcr_cf,
                id=erweiterteVertragid CFDate);
%compare_tables(base=g_392.vorgabe_cf,
                compare=PCR392.vorgabe_cf,
                drop=,
                outname=gks265_vorgabe_cf,
                id=erweiterteVertragid CFDate);
%compare_tables(base=g_392.cf_direktrwa,
                compare=PCR392.cf_direktrwa,
                drop=,
                outname=gks265_cf_direktrwa,
                id=aktenz cfdate);


* hier Prüfung der Eingabetabellen zu PCR457, eine Eingabedatei muss zu Abweichungen führen;
libname g_312 "E:\TS\GKS-265\Daten\PCR\PCR312";
%compare_tables(base=g_312.vertrag_koko_heute,
                compare=PCR312.vertrag_koko_heute,
                drop=,
                outname=gks265_vertrag_kk_heute,
                id=kreditid dt_kondition_gueltig);

libname g_510 "E:\TS\GKS-265\Daten\PCR\PCR510";
%compare_tables(base=g_510.d_h,
                compare=PCR510.d_h,
                drop=,
                outname=gks265_d_h,
                id=datum referenz waehrung tage);


* Vergleich der PCR457.MARGENTRIGGER aus der Nachberechnung in GKS-265 mit der Nachberechnung in dieser Umgebung;
* ?????;
libname g_457 "E:\TS\GKS-265\Daten\PCR\PCR457";
* diese Tabelle ist ungleich;
%compare_tables(base=g_457.cf_delta,
                compare=PCR457.cf_delta,
                drop=,
                outname=gks265_cf_delta,
                id=ErweiterteVertragID cfdate);
%compare_tables(base=g_457.cf_error,
                compare=PCR457.cf_error,
                drop=,
                outname=gks265_cf_error,
                id=kreditID);
%compare_tables(base=g_457.cf_parm,
                compare=PCR457.cf_parm,
                drop=,
                outname=gks265_cf_parm,
                id=h_lfdnr);
%compare_tables(base=g_457.cf_relevante,
                compare=PCR457.cf_relevante,
                drop=,
                outname=gks265_cf_relevante,
                id=ErweiterteVertragID aktenz);
%compare_tables(base=g_457.cf_v1,
                compare=PCR457.cf_v1,
                drop=,
                outname=gks265_cf_v1,
                id=ErweiterteVertragID cfdate);
%compare_tables(base=g_457.cf_v2,
                compare=PCR457.cf_v2,
                drop=,
                outname=gks265_cf_v2,
                id=ErweiterteVertragID cfdate);
%compare_tables(base=g_457.margentrigger,
                compare=PCR457.margentrigger,
                drop=,
                outname=gks265_margentrigger,
                id=ErweiterteVertragID ltzadate Methodentyp TriggerId KredProX ist_cmlv dt_refi  dt_ZinsB DT_Kondende Ausstad M_Ausstad AuszKurs Zinsper Nomzins ZInszus margkalk Zinsmeth zinsref  Referenz DT_Refi Hinweismeldung_pcr457 spread_BP spread_EUR);
%compare_tables(base=g_457.kfw_relevant,
                compare=PCR457.kfw_relevant,
                drop=,
                outname=gks265_kfw_relevant,
                id=ErweiterteVertragID referenz_nummer);
%compare_tables(base=g_457.pcr392_pcr_cf,
                compare=PCR457.pcr392_pcr_cf,
                drop=,
                outname=gks265_pcr392_pcr_cf,
                id=ErweiterteVertragID cfdate);
%compare_tables(base=g_sap2pcr.pcr392_pcr_cf,
                compare=PCR457.pcr392_pcr_cf,
                drop=,
                outname=gks265_pcr392_pcr_cf,
                id=ErweiterteVertragID cfdate);

* Vergleich der PCR507.CF_SBS Nachberechnung in GKS-265 mit der Nachberechnung in dieser Umgebung;
* ungleich ???;
libname g_507 "E:\TS\GKS-265\Daten\PCR\PCR507";
%compare_tables(base=g_507.cf_sbs,
                compare=PCR507.cf_sbs,
                drop=,
                outname=gks265_cf_sbs,
                id=kreditid cfdate);
%compare_tables(base=g_507.cf_delta_pcr2sbs,
                compare=PCR507.cf_delta_pcr2sbs,
                drop=,
                outname=gks265_cf_delta_pcr2sbs,
                id=kreditid cfdate);






* Vergleich der AZVorgabe aus der Nachberechnung in GKS-265 mit der Nachberechnung in dieser Umgebung;
* Ungleich;
libname g_465 "E:\TS\GKS-265\Daten\PCR\PCR465";
%compare_tables(base=g_465.azvorgabe,
                compare=pcr465.azvorgabe,
                drop=ID DNNummer,
                outname=gks265_pcr465_azvorgabe,
                id=erweitertevertragid profitcenter);
%shorten_compare(compare, gks265_pcr465_azvorgabe, keep=erweitertevertragid profitcenter);


%finish;
