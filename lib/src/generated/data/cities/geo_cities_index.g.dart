// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: sot/cities/*.json
//
// Routing and lookup helpers for per-country cities tables.

import '../../../models/geo_city.dart';
import '../../../models/geo_country_iso2.dart';
import '../states/geo_states_lookup.g.dart';
import 'geo_cities_ad.g.dart';
import 'geo_cities_ad_index.g.dart';
import 'geo_cities_ae.g.dart';
import 'geo_cities_ae_index.g.dart';
import 'geo_cities_af.g.dart';
import 'geo_cities_af_index.g.dart';
import 'geo_cities_ag.g.dart';
import 'geo_cities_ag_index.g.dart';
import 'geo_cities_al.g.dart';
import 'geo_cities_al_index.g.dart';
import 'geo_cities_am.g.dart';
import 'geo_cities_am_index.g.dart';
import 'geo_cities_ao.g.dart';
import 'geo_cities_ao_index.g.dart';
import 'geo_cities_ar.g.dart';
import 'geo_cities_ar_index.g.dart';
import 'geo_cities_at.g.dart';
import 'geo_cities_at_index.g.dart';
import 'geo_cities_au.g.dart';
import 'geo_cities_au_index.g.dart';
import 'geo_cities_az.g.dart';
import 'geo_cities_az_index.g.dart';
import 'geo_cities_ba.g.dart';
import 'geo_cities_ba_index.g.dart';
import 'geo_cities_bb.g.dart';
import 'geo_cities_bb_index.g.dart';
import 'geo_cities_bd.g.dart';
import 'geo_cities_bd_index.g.dart';
import 'geo_cities_be.g.dart';
import 'geo_cities_be_index.g.dart';
import 'geo_cities_bf.g.dart';
import 'geo_cities_bf_index.g.dart';
import 'geo_cities_bg.g.dart';
import 'geo_cities_bg_index.g.dart';
import 'geo_cities_bh.g.dart';
import 'geo_cities_bh_index.g.dart';
import 'geo_cities_bi.g.dart';
import 'geo_cities_bi_index.g.dart';
import 'geo_cities_bj.g.dart';
import 'geo_cities_bj_index.g.dart';
import 'geo_cities_bn.g.dart';
import 'geo_cities_bn_index.g.dart';
import 'geo_cities_bo.g.dart';
import 'geo_cities_bo_index.g.dart';
import 'geo_cities_br.g.dart';
import 'geo_cities_br_index.g.dart';
import 'geo_cities_bs.g.dart';
import 'geo_cities_bs_index.g.dart';
import 'geo_cities_bt.g.dart';
import 'geo_cities_bt_index.g.dart';
import 'geo_cities_bw.g.dart';
import 'geo_cities_bw_index.g.dart';
import 'geo_cities_by.g.dart';
import 'geo_cities_by_index.g.dart';
import 'geo_cities_bz.g.dart';
import 'geo_cities_bz_index.g.dart';
import 'geo_cities_ca.g.dart';
import 'geo_cities_ca_index.g.dart';
import 'geo_cities_cd.g.dart';
import 'geo_cities_cd_index.g.dart';
import 'geo_cities_cf.g.dart';
import 'geo_cities_cf_index.g.dart';
import 'geo_cities_cg.g.dart';
import 'geo_cities_cg_index.g.dart';
import 'geo_cities_ch.g.dart';
import 'geo_cities_ch_index.g.dart';
import 'geo_cities_ci.g.dart';
import 'geo_cities_ci_index.g.dart';
import 'geo_cities_cl.g.dart';
import 'geo_cities_cl_index.g.dart';
import 'geo_cities_cm.g.dart';
import 'geo_cities_cm_index.g.dart';
import 'geo_cities_cn.g.dart';
import 'geo_cities_cn_index.g.dart';
import 'geo_cities_co.g.dart';
import 'geo_cities_co_index.g.dart';
import 'geo_cities_cr.g.dart';
import 'geo_cities_cr_index.g.dart';
import 'geo_cities_cu.g.dart';
import 'geo_cities_cu_index.g.dart';
import 'geo_cities_cv.g.dart';
import 'geo_cities_cv_index.g.dart';
import 'geo_cities_cy.g.dart';
import 'geo_cities_cy_index.g.dart';
import 'geo_cities_cz.g.dart';
import 'geo_cities_cz_index.g.dart';
import 'geo_cities_de.g.dart';
import 'geo_cities_de_index.g.dart';
import 'geo_cities_dj.g.dart';
import 'geo_cities_dj_index.g.dart';
import 'geo_cities_dk.g.dart';
import 'geo_cities_dk_index.g.dart';
import 'geo_cities_dm.g.dart';
import 'geo_cities_dm_index.g.dart';
import 'geo_cities_do.g.dart';
import 'geo_cities_do_index.g.dart';
import 'geo_cities_dz.g.dart';
import 'geo_cities_dz_index.g.dart';
import 'geo_cities_ec.g.dart';
import 'geo_cities_ec_index.g.dart';
import 'geo_cities_ee.g.dart';
import 'geo_cities_ee_index.g.dart';
import 'geo_cities_eg.g.dart';
import 'geo_cities_eg_index.g.dart';
import 'geo_cities_er.g.dart';
import 'geo_cities_er_index.g.dart';
import 'geo_cities_es.g.dart';
import 'geo_cities_es_index.g.dart';
import 'geo_cities_et.g.dart';
import 'geo_cities_et_index.g.dart';
import 'geo_cities_fi.g.dart';
import 'geo_cities_fi_index.g.dart';
import 'geo_cities_fj.g.dart';
import 'geo_cities_fj_index.g.dart';
import 'geo_cities_fm.g.dart';
import 'geo_cities_fm_index.g.dart';
import 'geo_cities_fr.g.dart';
import 'geo_cities_fr_index.g.dart';
import 'geo_cities_ga.g.dart';
import 'geo_cities_ga_index.g.dart';
import 'geo_cities_gb.g.dart';
import 'geo_cities_gb_index.g.dart';
import 'geo_cities_gd.g.dart';
import 'geo_cities_gd_index.g.dart';
import 'geo_cities_ge.g.dart';
import 'geo_cities_ge_index.g.dart';
import 'geo_cities_gh.g.dart';
import 'geo_cities_gh_index.g.dart';
import 'geo_cities_gm.g.dart';
import 'geo_cities_gm_index.g.dart';
import 'geo_cities_gn.g.dart';
import 'geo_cities_gn_index.g.dart';
import 'geo_cities_gq.g.dart';
import 'geo_cities_gq_index.g.dart';
import 'geo_cities_gr.g.dart';
import 'geo_cities_gr_index.g.dart';
import 'geo_cities_gt.g.dart';
import 'geo_cities_gt_index.g.dart';
import 'geo_cities_gw.g.dart';
import 'geo_cities_gw_index.g.dart';
import 'geo_cities_gy.g.dart';
import 'geo_cities_gy_index.g.dart';
import 'geo_cities_hn.g.dart';
import 'geo_cities_hn_index.g.dart';
import 'geo_cities_hr.g.dart';
import 'geo_cities_hr_index.g.dart';
import 'geo_cities_ht.g.dart';
import 'geo_cities_ht_index.g.dart';
import 'geo_cities_hu.g.dart';
import 'geo_cities_hu_index.g.dart';
import 'geo_cities_id.g.dart';
import 'geo_cities_id_index.g.dart';
import 'geo_cities_ie.g.dart';
import 'geo_cities_ie_index.g.dart';
import 'geo_cities_il.g.dart';
import 'geo_cities_il_index.g.dart';
import 'geo_cities_in.g.dart';
import 'geo_cities_in_index.g.dart';
import 'geo_cities_iq.g.dart';
import 'geo_cities_iq_index.g.dart';
import 'geo_cities_ir.g.dart';
import 'geo_cities_ir_index.g.dart';
import 'geo_cities_is.g.dart';
import 'geo_cities_is_index.g.dart';
import 'geo_cities_it.g.dart';
import 'geo_cities_it_index.g.dart';
import 'geo_cities_jm.g.dart';
import 'geo_cities_jm_index.g.dart';
import 'geo_cities_jo.g.dart';
import 'geo_cities_jo_index.g.dart';
import 'geo_cities_jp.g.dart';
import 'geo_cities_jp_index.g.dart';
import 'geo_cities_ke.g.dart';
import 'geo_cities_ke_index.g.dart';
import 'geo_cities_kg.g.dart';
import 'geo_cities_kg_index.g.dart';
import 'geo_cities_kh.g.dart';
import 'geo_cities_kh_index.g.dart';
import 'geo_cities_ki.g.dart';
import 'geo_cities_ki_index.g.dart';
import 'geo_cities_km.g.dart';
import 'geo_cities_km_index.g.dart';
import 'geo_cities_kn.g.dart';
import 'geo_cities_kn_index.g.dart';
import 'geo_cities_kp.g.dart';
import 'geo_cities_kp_index.g.dart';
import 'geo_cities_kr.g.dart';
import 'geo_cities_kr_index.g.dart';
import 'geo_cities_kw.g.dart';
import 'geo_cities_kw_index.g.dart';
import 'geo_cities_kz.g.dart';
import 'geo_cities_kz_index.g.dart';
import 'geo_cities_la.g.dart';
import 'geo_cities_la_index.g.dart';
import 'geo_cities_lb.g.dart';
import 'geo_cities_lb_index.g.dart';
import 'geo_cities_lc.g.dart';
import 'geo_cities_lc_index.g.dart';
import 'geo_cities_li.g.dart';
import 'geo_cities_li_index.g.dart';
import 'geo_cities_lk.g.dart';
import 'geo_cities_lk_index.g.dart';
import 'geo_cities_lr.g.dart';
import 'geo_cities_lr_index.g.dart';
import 'geo_cities_ls.g.dart';
import 'geo_cities_ls_index.g.dart';
import 'geo_cities_lt.g.dart';
import 'geo_cities_lt_index.g.dart';
import 'geo_cities_lu.g.dart';
import 'geo_cities_lu_index.g.dart';
import 'geo_cities_lv.g.dart';
import 'geo_cities_lv_index.g.dart';
import 'geo_cities_ly.g.dart';
import 'geo_cities_ly_index.g.dart';
import 'geo_cities_ma.g.dart';
import 'geo_cities_ma_index.g.dart';
import 'geo_cities_md.g.dart';
import 'geo_cities_md_index.g.dart';
import 'geo_cities_me.g.dart';
import 'geo_cities_me_index.g.dart';
import 'geo_cities_mg.g.dart';
import 'geo_cities_mg_index.g.dart';
import 'geo_cities_mk.g.dart';
import 'geo_cities_mk_index.g.dart';
import 'geo_cities_ml.g.dart';
import 'geo_cities_ml_index.g.dart';
import 'geo_cities_mm.g.dart';
import 'geo_cities_mm_index.g.dart';
import 'geo_cities_mn.g.dart';
import 'geo_cities_mn_index.g.dart';
import 'geo_cities_mr.g.dart';
import 'geo_cities_mr_index.g.dart';
import 'geo_cities_mt.g.dart';
import 'geo_cities_mt_index.g.dart';
import 'geo_cities_mu.g.dart';
import 'geo_cities_mu_index.g.dart';
import 'geo_cities_mv.g.dart';
import 'geo_cities_mv_index.g.dart';
import 'geo_cities_mw.g.dart';
import 'geo_cities_mw_index.g.dart';
import 'geo_cities_mx.g.dart';
import 'geo_cities_mx_index.g.dart';
import 'geo_cities_my.g.dart';
import 'geo_cities_my_index.g.dart';
import 'geo_cities_mz.g.dart';
import 'geo_cities_mz_index.g.dart';
import 'geo_cities_na.g.dart';
import 'geo_cities_na_index.g.dart';
import 'geo_cities_ne.g.dart';
import 'geo_cities_ne_index.g.dart';
import 'geo_cities_ng.g.dart';
import 'geo_cities_ng_index.g.dart';
import 'geo_cities_ni.g.dart';
import 'geo_cities_ni_index.g.dart';
import 'geo_cities_nl.g.dart';
import 'geo_cities_nl_index.g.dart';
import 'geo_cities_no.g.dart';
import 'geo_cities_no_index.g.dart';
import 'geo_cities_np.g.dart';
import 'geo_cities_np_index.g.dart';
import 'geo_cities_nr.g.dart';
import 'geo_cities_nr_index.g.dart';
import 'geo_cities_nz.g.dart';
import 'geo_cities_nz_index.g.dart';
import 'geo_cities_om.g.dart';
import 'geo_cities_om_index.g.dart';
import 'geo_cities_pa.g.dart';
import 'geo_cities_pa_index.g.dart';
import 'geo_cities_pe.g.dart';
import 'geo_cities_pe_index.g.dart';
import 'geo_cities_pg.g.dart';
import 'geo_cities_pg_index.g.dart';
import 'geo_cities_ph.g.dart';
import 'geo_cities_ph_index.g.dart';
import 'geo_cities_pk.g.dart';
import 'geo_cities_pk_index.g.dart';
import 'geo_cities_pl.g.dart';
import 'geo_cities_pl_index.g.dart';
import 'geo_cities_pt.g.dart';
import 'geo_cities_pt_index.g.dart';
import 'geo_cities_pw.g.dart';
import 'geo_cities_pw_index.g.dart';
import 'geo_cities_py.g.dart';
import 'geo_cities_py_index.g.dart';
import 'geo_cities_qa.g.dart';
import 'geo_cities_qa_index.g.dart';
import 'geo_cities_ro.g.dart';
import 'geo_cities_ro_index.g.dart';
import 'geo_cities_rs.g.dart';
import 'geo_cities_rs_index.g.dart';
import 'geo_cities_ru.g.dart';
import 'geo_cities_ru_index.g.dart';
import 'geo_cities_rw.g.dart';
import 'geo_cities_rw_index.g.dart';
import 'geo_cities_sa.g.dart';
import 'geo_cities_sa_index.g.dart';
import 'geo_cities_sb.g.dart';
import 'geo_cities_sb_index.g.dart';
import 'geo_cities_sc.g.dart';
import 'geo_cities_sc_index.g.dart';
import 'geo_cities_sd.g.dart';
import 'geo_cities_sd_index.g.dart';
import 'geo_cities_se.g.dart';
import 'geo_cities_se_index.g.dart';
import 'geo_cities_sg.g.dart';
import 'geo_cities_sg_index.g.dart';
import 'geo_cities_si.g.dart';
import 'geo_cities_si_index.g.dart';
import 'geo_cities_sk.g.dart';
import 'geo_cities_sk_index.g.dart';
import 'geo_cities_sl.g.dart';
import 'geo_cities_sl_index.g.dart';
import 'geo_cities_sm.g.dart';
import 'geo_cities_sm_index.g.dart';
import 'geo_cities_sn.g.dart';
import 'geo_cities_sn_index.g.dart';
import 'geo_cities_so.g.dart';
import 'geo_cities_so_index.g.dart';
import 'geo_cities_sr.g.dart';
import 'geo_cities_sr_index.g.dart';
import 'geo_cities_ss.g.dart';
import 'geo_cities_ss_index.g.dart';
import 'geo_cities_st.g.dart';
import 'geo_cities_st_index.g.dart';
import 'geo_cities_sv.g.dart';
import 'geo_cities_sv_index.g.dart';
import 'geo_cities_sy.g.dart';
import 'geo_cities_sy_index.g.dart';
import 'geo_cities_sz.g.dart';
import 'geo_cities_sz_index.g.dart';
import 'geo_cities_td.g.dart';
import 'geo_cities_td_index.g.dart';
import 'geo_cities_tg.g.dart';
import 'geo_cities_tg_index.g.dart';
import 'geo_cities_th.g.dart';
import 'geo_cities_th_index.g.dart';
import 'geo_cities_tj.g.dart';
import 'geo_cities_tj_index.g.dart';
import 'geo_cities_tl.g.dart';
import 'geo_cities_tl_index.g.dart';
import 'geo_cities_tm.g.dart';
import 'geo_cities_tm_index.g.dart';
import 'geo_cities_tn.g.dart';
import 'geo_cities_tn_index.g.dart';
import 'geo_cities_to.g.dart';
import 'geo_cities_to_index.g.dart';
import 'geo_cities_tr.g.dart';
import 'geo_cities_tr_index.g.dart';
import 'geo_cities_tt.g.dart';
import 'geo_cities_tt_index.g.dart';
import 'geo_cities_tv.g.dart';
import 'geo_cities_tv_index.g.dart';
import 'geo_cities_tw.g.dart';
import 'geo_cities_tw_index.g.dart';
import 'geo_cities_tz.g.dart';
import 'geo_cities_tz_index.g.dart';
import 'geo_cities_ua.g.dart';
import 'geo_cities_ua_index.g.dart';
import 'geo_cities_ug.g.dart';
import 'geo_cities_ug_index.g.dart';
import 'geo_cities_us.g.dart';
import 'geo_cities_us_index.g.dart';
import 'geo_cities_uy.g.dart';
import 'geo_cities_uy_index.g.dart';
import 'geo_cities_uz.g.dart';
import 'geo_cities_uz_index.g.dart';
import 'geo_cities_vc.g.dart';
import 'geo_cities_vc_index.g.dart';
import 'geo_cities_ve.g.dart';
import 'geo_cities_ve_index.g.dart';
import 'geo_cities_vn.g.dart';
import 'geo_cities_vn_index.g.dart';
import 'geo_cities_vu.g.dart';
import 'geo_cities_vu_index.g.dart';
import 'geo_cities_ws.g.dart';
import 'geo_cities_ws_index.g.dart';
import 'geo_cities_ye.g.dart';
import 'geo_cities_ye_index.g.dart';
import 'geo_cities_za.g.dart';
import 'geo_cities_za_index.g.dart';
import 'geo_cities_zm.g.dart';
import 'geo_cities_zm_index.g.dart';
import 'geo_cities_zw.g.dart';
import 'geo_cities_zw_index.g.dart';

List<GeoCity> geoCitiesOfCountry(GeoCountryIso2 iso2) =>
    switch (iso2) {
      GeoCountryIso2.AD => kGeoCities_AD,
      GeoCountryIso2.AE => kGeoCities_AE,
      GeoCountryIso2.AF => kGeoCities_AF,
      GeoCountryIso2.AG => kGeoCities_AG,
      GeoCountryIso2.AL => kGeoCities_AL,
      GeoCountryIso2.AM => kGeoCities_AM,
      GeoCountryIso2.AO => kGeoCities_AO,
      GeoCountryIso2.AR => kGeoCities_AR,
      GeoCountryIso2.AT => kGeoCities_AT,
      GeoCountryIso2.AU => kGeoCities_AU,
      GeoCountryIso2.AZ => kGeoCities_AZ,
      GeoCountryIso2.BA => kGeoCities_BA,
      GeoCountryIso2.BB => kGeoCities_BB,
      GeoCountryIso2.BD => kGeoCities_BD,
      GeoCountryIso2.BE => kGeoCities_BE,
      GeoCountryIso2.BF => kGeoCities_BF,
      GeoCountryIso2.BG => kGeoCities_BG,
      GeoCountryIso2.BH => kGeoCities_BH,
      GeoCountryIso2.BI => kGeoCities_BI,
      GeoCountryIso2.BJ => kGeoCities_BJ,
      GeoCountryIso2.BN => kGeoCities_BN,
      GeoCountryIso2.BO => kGeoCities_BO,
      GeoCountryIso2.BR => kGeoCities_BR,
      GeoCountryIso2.BS => kGeoCities_BS,
      GeoCountryIso2.BT => kGeoCities_BT,
      GeoCountryIso2.BW => kGeoCities_BW,
      GeoCountryIso2.BY => kGeoCities_BY,
      GeoCountryIso2.BZ => kGeoCities_BZ,
      GeoCountryIso2.CA => kGeoCities_CA,
      GeoCountryIso2.CD => kGeoCities_CD,
      GeoCountryIso2.CF => kGeoCities_CF,
      GeoCountryIso2.CG => kGeoCities_CG,
      GeoCountryIso2.CH => kGeoCities_CH,
      GeoCountryIso2.CI => kGeoCities_CI,
      GeoCountryIso2.CL => kGeoCities_CL,
      GeoCountryIso2.CM => kGeoCities_CM,
      GeoCountryIso2.CN => kGeoCities_CN,
      GeoCountryIso2.CO => kGeoCities_CO,
      GeoCountryIso2.CR => kGeoCities_CR,
      GeoCountryIso2.CU => kGeoCities_CU,
      GeoCountryIso2.CV => kGeoCities_CV,
      GeoCountryIso2.CY => kGeoCities_CY,
      GeoCountryIso2.CZ => kGeoCities_CZ,
      GeoCountryIso2.DE => kGeoCities_DE,
      GeoCountryIso2.DJ => kGeoCities_DJ,
      GeoCountryIso2.DK => kGeoCities_DK,
      GeoCountryIso2.DM => kGeoCities_DM,
      GeoCountryIso2.DO => kGeoCities_DO,
      GeoCountryIso2.DZ => kGeoCities_DZ,
      GeoCountryIso2.EC => kGeoCities_EC,
      GeoCountryIso2.EE => kGeoCities_EE,
      GeoCountryIso2.EG => kGeoCities_EG,
      GeoCountryIso2.ER => kGeoCities_ER,
      GeoCountryIso2.ES => kGeoCities_ES,
      GeoCountryIso2.ET => kGeoCities_ET,
      GeoCountryIso2.FI => kGeoCities_FI,
      GeoCountryIso2.FJ => kGeoCities_FJ,
      GeoCountryIso2.FM => kGeoCities_FM,
      GeoCountryIso2.FR => kGeoCities_FR,
      GeoCountryIso2.GA => kGeoCities_GA,
      GeoCountryIso2.GB => kGeoCities_GB,
      GeoCountryIso2.GD => kGeoCities_GD,
      GeoCountryIso2.GE => kGeoCities_GE,
      GeoCountryIso2.GH => kGeoCities_GH,
      GeoCountryIso2.GM => kGeoCities_GM,
      GeoCountryIso2.GN => kGeoCities_GN,
      GeoCountryIso2.GQ => kGeoCities_GQ,
      GeoCountryIso2.GR => kGeoCities_GR,
      GeoCountryIso2.GT => kGeoCities_GT,
      GeoCountryIso2.GW => kGeoCities_GW,
      GeoCountryIso2.GY => kGeoCities_GY,
      GeoCountryIso2.HN => kGeoCities_HN,
      GeoCountryIso2.HR => kGeoCities_HR,
      GeoCountryIso2.HT => kGeoCities_HT,
      GeoCountryIso2.HU => kGeoCities_HU,
      GeoCountryIso2.ID => kGeoCities_ID,
      GeoCountryIso2.IE => kGeoCities_IE,
      GeoCountryIso2.IL => kGeoCities_IL,
      GeoCountryIso2.IN => kGeoCities_IN,
      GeoCountryIso2.IQ => kGeoCities_IQ,
      GeoCountryIso2.IR => kGeoCities_IR,
      GeoCountryIso2.IS => kGeoCities_IS,
      GeoCountryIso2.IT => kGeoCities_IT,
      GeoCountryIso2.JM => kGeoCities_JM,
      GeoCountryIso2.JO => kGeoCities_JO,
      GeoCountryIso2.JP => kGeoCities_JP,
      GeoCountryIso2.KE => kGeoCities_KE,
      GeoCountryIso2.KG => kGeoCities_KG,
      GeoCountryIso2.KH => kGeoCities_KH,
      GeoCountryIso2.KI => kGeoCities_KI,
      GeoCountryIso2.KM => kGeoCities_KM,
      GeoCountryIso2.KN => kGeoCities_KN,
      GeoCountryIso2.KP => kGeoCities_KP,
      GeoCountryIso2.KR => kGeoCities_KR,
      GeoCountryIso2.KW => kGeoCities_KW,
      GeoCountryIso2.KZ => kGeoCities_KZ,
      GeoCountryIso2.LA => kGeoCities_LA,
      GeoCountryIso2.LB => kGeoCities_LB,
      GeoCountryIso2.LC => kGeoCities_LC,
      GeoCountryIso2.LI => kGeoCities_LI,
      GeoCountryIso2.LK => kGeoCities_LK,
      GeoCountryIso2.LR => kGeoCities_LR,
      GeoCountryIso2.LS => kGeoCities_LS,
      GeoCountryIso2.LT => kGeoCities_LT,
      GeoCountryIso2.LU => kGeoCities_LU,
      GeoCountryIso2.LV => kGeoCities_LV,
      GeoCountryIso2.LY => kGeoCities_LY,
      GeoCountryIso2.MA => kGeoCities_MA,
      GeoCountryIso2.MD => kGeoCities_MD,
      GeoCountryIso2.ME => kGeoCities_ME,
      GeoCountryIso2.MG => kGeoCities_MG,
      GeoCountryIso2.MK => kGeoCities_MK,
      GeoCountryIso2.ML => kGeoCities_ML,
      GeoCountryIso2.MM => kGeoCities_MM,
      GeoCountryIso2.MN => kGeoCities_MN,
      GeoCountryIso2.MR => kGeoCities_MR,
      GeoCountryIso2.MT => kGeoCities_MT,
      GeoCountryIso2.MU => kGeoCities_MU,
      GeoCountryIso2.MV => kGeoCities_MV,
      GeoCountryIso2.MW => kGeoCities_MW,
      GeoCountryIso2.MX => kGeoCities_MX,
      GeoCountryIso2.MY => kGeoCities_MY,
      GeoCountryIso2.MZ => kGeoCities_MZ,
      GeoCountryIso2.NA => kGeoCities_NA,
      GeoCountryIso2.NE => kGeoCities_NE,
      GeoCountryIso2.NG => kGeoCities_NG,
      GeoCountryIso2.NI => kGeoCities_NI,
      GeoCountryIso2.NL => kGeoCities_NL,
      GeoCountryIso2.NO => kGeoCities_NO,
      GeoCountryIso2.NP => kGeoCities_NP,
      GeoCountryIso2.NR => kGeoCities_NR,
      GeoCountryIso2.NZ => kGeoCities_NZ,
      GeoCountryIso2.OM => kGeoCities_OM,
      GeoCountryIso2.PA => kGeoCities_PA,
      GeoCountryIso2.PE => kGeoCities_PE,
      GeoCountryIso2.PG => kGeoCities_PG,
      GeoCountryIso2.PH => kGeoCities_PH,
      GeoCountryIso2.PK => kGeoCities_PK,
      GeoCountryIso2.PL => kGeoCities_PL,
      GeoCountryIso2.PT => kGeoCities_PT,
      GeoCountryIso2.PW => kGeoCities_PW,
      GeoCountryIso2.PY => kGeoCities_PY,
      GeoCountryIso2.QA => kGeoCities_QA,
      GeoCountryIso2.RO => kGeoCities_RO,
      GeoCountryIso2.RS => kGeoCities_RS,
      GeoCountryIso2.RU => kGeoCities_RU,
      GeoCountryIso2.RW => kGeoCities_RW,
      GeoCountryIso2.SA => kGeoCities_SA,
      GeoCountryIso2.SB => kGeoCities_SB,
      GeoCountryIso2.SC => kGeoCities_SC,
      GeoCountryIso2.SD => kGeoCities_SD,
      GeoCountryIso2.SE => kGeoCities_SE,
      GeoCountryIso2.SG => kGeoCities_SG,
      GeoCountryIso2.SI => kGeoCities_SI,
      GeoCountryIso2.SK => kGeoCities_SK,
      GeoCountryIso2.SL => kGeoCities_SL,
      GeoCountryIso2.SM => kGeoCities_SM,
      GeoCountryIso2.SN => kGeoCities_SN,
      GeoCountryIso2.SO => kGeoCities_SO,
      GeoCountryIso2.SR => kGeoCities_SR,
      GeoCountryIso2.SS => kGeoCities_SS,
      GeoCountryIso2.ST => kGeoCities_ST,
      GeoCountryIso2.SV => kGeoCities_SV,
      GeoCountryIso2.SY => kGeoCities_SY,
      GeoCountryIso2.SZ => kGeoCities_SZ,
      GeoCountryIso2.TD => kGeoCities_TD,
      GeoCountryIso2.TG => kGeoCities_TG,
      GeoCountryIso2.TH => kGeoCities_TH,
      GeoCountryIso2.TJ => kGeoCities_TJ,
      GeoCountryIso2.TL => kGeoCities_TL,
      GeoCountryIso2.TM => kGeoCities_TM,
      GeoCountryIso2.TN => kGeoCities_TN,
      GeoCountryIso2.TO => kGeoCities_TO,
      GeoCountryIso2.TR => kGeoCities_TR,
      GeoCountryIso2.TT => kGeoCities_TT,
      GeoCountryIso2.TV => kGeoCities_TV,
      GeoCountryIso2.TW => kGeoCities_TW,
      GeoCountryIso2.TZ => kGeoCities_TZ,
      GeoCountryIso2.UA => kGeoCities_UA,
      GeoCountryIso2.UG => kGeoCities_UG,
      GeoCountryIso2.US => kGeoCities_US,
      GeoCountryIso2.UY => kGeoCities_UY,
      GeoCountryIso2.UZ => kGeoCities_UZ,
      GeoCountryIso2.VC => kGeoCities_VC,
      GeoCountryIso2.VE => kGeoCities_VE,
      GeoCountryIso2.VN => kGeoCities_VN,
      GeoCountryIso2.VU => kGeoCities_VU,
      GeoCountryIso2.WS => kGeoCities_WS,
      GeoCountryIso2.YE => kGeoCities_YE,
      GeoCountryIso2.ZA => kGeoCities_ZA,
      GeoCountryIso2.ZM => kGeoCities_ZM,
      GeoCountryIso2.ZW => kGeoCities_ZW,
      _ => const <GeoCity>[],
    };

(List<GeoCity>, List<int>)? geoCityIndicesForState(String stateId) {
  final state = kGeoStateById[stateId];
  if (state == null) return null;

  final country = state.countryIso2;
  final map = switch (country) {
      GeoCountryIso2.AD => kGeoCityIndexByState_AD,
      GeoCountryIso2.AE => kGeoCityIndexByState_AE,
      GeoCountryIso2.AF => kGeoCityIndexByState_AF,
      GeoCountryIso2.AG => kGeoCityIndexByState_AG,
      GeoCountryIso2.AL => kGeoCityIndexByState_AL,
      GeoCountryIso2.AM => kGeoCityIndexByState_AM,
      GeoCountryIso2.AO => kGeoCityIndexByState_AO,
      GeoCountryIso2.AR => kGeoCityIndexByState_AR,
      GeoCountryIso2.AT => kGeoCityIndexByState_AT,
      GeoCountryIso2.AU => kGeoCityIndexByState_AU,
      GeoCountryIso2.AZ => kGeoCityIndexByState_AZ,
      GeoCountryIso2.BA => kGeoCityIndexByState_BA,
      GeoCountryIso2.BB => kGeoCityIndexByState_BB,
      GeoCountryIso2.BD => kGeoCityIndexByState_BD,
      GeoCountryIso2.BE => kGeoCityIndexByState_BE,
      GeoCountryIso2.BF => kGeoCityIndexByState_BF,
      GeoCountryIso2.BG => kGeoCityIndexByState_BG,
      GeoCountryIso2.BH => kGeoCityIndexByState_BH,
      GeoCountryIso2.BI => kGeoCityIndexByState_BI,
      GeoCountryIso2.BJ => kGeoCityIndexByState_BJ,
      GeoCountryIso2.BN => kGeoCityIndexByState_BN,
      GeoCountryIso2.BO => kGeoCityIndexByState_BO,
      GeoCountryIso2.BR => kGeoCityIndexByState_BR,
      GeoCountryIso2.BS => kGeoCityIndexByState_BS,
      GeoCountryIso2.BT => kGeoCityIndexByState_BT,
      GeoCountryIso2.BW => kGeoCityIndexByState_BW,
      GeoCountryIso2.BY => kGeoCityIndexByState_BY,
      GeoCountryIso2.BZ => kGeoCityIndexByState_BZ,
      GeoCountryIso2.CA => kGeoCityIndexByState_CA,
      GeoCountryIso2.CD => kGeoCityIndexByState_CD,
      GeoCountryIso2.CF => kGeoCityIndexByState_CF,
      GeoCountryIso2.CG => kGeoCityIndexByState_CG,
      GeoCountryIso2.CH => kGeoCityIndexByState_CH,
      GeoCountryIso2.CI => kGeoCityIndexByState_CI,
      GeoCountryIso2.CL => kGeoCityIndexByState_CL,
      GeoCountryIso2.CM => kGeoCityIndexByState_CM,
      GeoCountryIso2.CN => kGeoCityIndexByState_CN,
      GeoCountryIso2.CO => kGeoCityIndexByState_CO,
      GeoCountryIso2.CR => kGeoCityIndexByState_CR,
      GeoCountryIso2.CU => kGeoCityIndexByState_CU,
      GeoCountryIso2.CV => kGeoCityIndexByState_CV,
      GeoCountryIso2.CY => kGeoCityIndexByState_CY,
      GeoCountryIso2.CZ => kGeoCityIndexByState_CZ,
      GeoCountryIso2.DE => kGeoCityIndexByState_DE,
      GeoCountryIso2.DJ => kGeoCityIndexByState_DJ,
      GeoCountryIso2.DK => kGeoCityIndexByState_DK,
      GeoCountryIso2.DM => kGeoCityIndexByState_DM,
      GeoCountryIso2.DO => kGeoCityIndexByState_DO,
      GeoCountryIso2.DZ => kGeoCityIndexByState_DZ,
      GeoCountryIso2.EC => kGeoCityIndexByState_EC,
      GeoCountryIso2.EE => kGeoCityIndexByState_EE,
      GeoCountryIso2.EG => kGeoCityIndexByState_EG,
      GeoCountryIso2.ER => kGeoCityIndexByState_ER,
      GeoCountryIso2.ES => kGeoCityIndexByState_ES,
      GeoCountryIso2.ET => kGeoCityIndexByState_ET,
      GeoCountryIso2.FI => kGeoCityIndexByState_FI,
      GeoCountryIso2.FJ => kGeoCityIndexByState_FJ,
      GeoCountryIso2.FM => kGeoCityIndexByState_FM,
      GeoCountryIso2.FR => kGeoCityIndexByState_FR,
      GeoCountryIso2.GA => kGeoCityIndexByState_GA,
      GeoCountryIso2.GB => kGeoCityIndexByState_GB,
      GeoCountryIso2.GD => kGeoCityIndexByState_GD,
      GeoCountryIso2.GE => kGeoCityIndexByState_GE,
      GeoCountryIso2.GH => kGeoCityIndexByState_GH,
      GeoCountryIso2.GM => kGeoCityIndexByState_GM,
      GeoCountryIso2.GN => kGeoCityIndexByState_GN,
      GeoCountryIso2.GQ => kGeoCityIndexByState_GQ,
      GeoCountryIso2.GR => kGeoCityIndexByState_GR,
      GeoCountryIso2.GT => kGeoCityIndexByState_GT,
      GeoCountryIso2.GW => kGeoCityIndexByState_GW,
      GeoCountryIso2.GY => kGeoCityIndexByState_GY,
      GeoCountryIso2.HN => kGeoCityIndexByState_HN,
      GeoCountryIso2.HR => kGeoCityIndexByState_HR,
      GeoCountryIso2.HT => kGeoCityIndexByState_HT,
      GeoCountryIso2.HU => kGeoCityIndexByState_HU,
      GeoCountryIso2.ID => kGeoCityIndexByState_ID,
      GeoCountryIso2.IE => kGeoCityIndexByState_IE,
      GeoCountryIso2.IL => kGeoCityIndexByState_IL,
      GeoCountryIso2.IN => kGeoCityIndexByState_IN,
      GeoCountryIso2.IQ => kGeoCityIndexByState_IQ,
      GeoCountryIso2.IR => kGeoCityIndexByState_IR,
      GeoCountryIso2.IS => kGeoCityIndexByState_IS,
      GeoCountryIso2.IT => kGeoCityIndexByState_IT,
      GeoCountryIso2.JM => kGeoCityIndexByState_JM,
      GeoCountryIso2.JO => kGeoCityIndexByState_JO,
      GeoCountryIso2.JP => kGeoCityIndexByState_JP,
      GeoCountryIso2.KE => kGeoCityIndexByState_KE,
      GeoCountryIso2.KG => kGeoCityIndexByState_KG,
      GeoCountryIso2.KH => kGeoCityIndexByState_KH,
      GeoCountryIso2.KI => kGeoCityIndexByState_KI,
      GeoCountryIso2.KM => kGeoCityIndexByState_KM,
      GeoCountryIso2.KN => kGeoCityIndexByState_KN,
      GeoCountryIso2.KP => kGeoCityIndexByState_KP,
      GeoCountryIso2.KR => kGeoCityIndexByState_KR,
      GeoCountryIso2.KW => kGeoCityIndexByState_KW,
      GeoCountryIso2.KZ => kGeoCityIndexByState_KZ,
      GeoCountryIso2.LA => kGeoCityIndexByState_LA,
      GeoCountryIso2.LB => kGeoCityIndexByState_LB,
      GeoCountryIso2.LC => kGeoCityIndexByState_LC,
      GeoCountryIso2.LI => kGeoCityIndexByState_LI,
      GeoCountryIso2.LK => kGeoCityIndexByState_LK,
      GeoCountryIso2.LR => kGeoCityIndexByState_LR,
      GeoCountryIso2.LS => kGeoCityIndexByState_LS,
      GeoCountryIso2.LT => kGeoCityIndexByState_LT,
      GeoCountryIso2.LU => kGeoCityIndexByState_LU,
      GeoCountryIso2.LV => kGeoCityIndexByState_LV,
      GeoCountryIso2.LY => kGeoCityIndexByState_LY,
      GeoCountryIso2.MA => kGeoCityIndexByState_MA,
      GeoCountryIso2.MD => kGeoCityIndexByState_MD,
      GeoCountryIso2.ME => kGeoCityIndexByState_ME,
      GeoCountryIso2.MG => kGeoCityIndexByState_MG,
      GeoCountryIso2.MK => kGeoCityIndexByState_MK,
      GeoCountryIso2.ML => kGeoCityIndexByState_ML,
      GeoCountryIso2.MM => kGeoCityIndexByState_MM,
      GeoCountryIso2.MN => kGeoCityIndexByState_MN,
      GeoCountryIso2.MR => kGeoCityIndexByState_MR,
      GeoCountryIso2.MT => kGeoCityIndexByState_MT,
      GeoCountryIso2.MU => kGeoCityIndexByState_MU,
      GeoCountryIso2.MV => kGeoCityIndexByState_MV,
      GeoCountryIso2.MW => kGeoCityIndexByState_MW,
      GeoCountryIso2.MX => kGeoCityIndexByState_MX,
      GeoCountryIso2.MY => kGeoCityIndexByState_MY,
      GeoCountryIso2.MZ => kGeoCityIndexByState_MZ,
      GeoCountryIso2.NA => kGeoCityIndexByState_NA,
      GeoCountryIso2.NE => kGeoCityIndexByState_NE,
      GeoCountryIso2.NG => kGeoCityIndexByState_NG,
      GeoCountryIso2.NI => kGeoCityIndexByState_NI,
      GeoCountryIso2.NL => kGeoCityIndexByState_NL,
      GeoCountryIso2.NO => kGeoCityIndexByState_NO,
      GeoCountryIso2.NP => kGeoCityIndexByState_NP,
      GeoCountryIso2.NR => kGeoCityIndexByState_NR,
      GeoCountryIso2.NZ => kGeoCityIndexByState_NZ,
      GeoCountryIso2.OM => kGeoCityIndexByState_OM,
      GeoCountryIso2.PA => kGeoCityIndexByState_PA,
      GeoCountryIso2.PE => kGeoCityIndexByState_PE,
      GeoCountryIso2.PG => kGeoCityIndexByState_PG,
      GeoCountryIso2.PH => kGeoCityIndexByState_PH,
      GeoCountryIso2.PK => kGeoCityIndexByState_PK,
      GeoCountryIso2.PL => kGeoCityIndexByState_PL,
      GeoCountryIso2.PT => kGeoCityIndexByState_PT,
      GeoCountryIso2.PW => kGeoCityIndexByState_PW,
      GeoCountryIso2.PY => kGeoCityIndexByState_PY,
      GeoCountryIso2.QA => kGeoCityIndexByState_QA,
      GeoCountryIso2.RO => kGeoCityIndexByState_RO,
      GeoCountryIso2.RS => kGeoCityIndexByState_RS,
      GeoCountryIso2.RU => kGeoCityIndexByState_RU,
      GeoCountryIso2.RW => kGeoCityIndexByState_RW,
      GeoCountryIso2.SA => kGeoCityIndexByState_SA,
      GeoCountryIso2.SB => kGeoCityIndexByState_SB,
      GeoCountryIso2.SC => kGeoCityIndexByState_SC,
      GeoCountryIso2.SD => kGeoCityIndexByState_SD,
      GeoCountryIso2.SE => kGeoCityIndexByState_SE,
      GeoCountryIso2.SG => kGeoCityIndexByState_SG,
      GeoCountryIso2.SI => kGeoCityIndexByState_SI,
      GeoCountryIso2.SK => kGeoCityIndexByState_SK,
      GeoCountryIso2.SL => kGeoCityIndexByState_SL,
      GeoCountryIso2.SM => kGeoCityIndexByState_SM,
      GeoCountryIso2.SN => kGeoCityIndexByState_SN,
      GeoCountryIso2.SO => kGeoCityIndexByState_SO,
      GeoCountryIso2.SR => kGeoCityIndexByState_SR,
      GeoCountryIso2.SS => kGeoCityIndexByState_SS,
      GeoCountryIso2.ST => kGeoCityIndexByState_ST,
      GeoCountryIso2.SV => kGeoCityIndexByState_SV,
      GeoCountryIso2.SY => kGeoCityIndexByState_SY,
      GeoCountryIso2.SZ => kGeoCityIndexByState_SZ,
      GeoCountryIso2.TD => kGeoCityIndexByState_TD,
      GeoCountryIso2.TG => kGeoCityIndexByState_TG,
      GeoCountryIso2.TH => kGeoCityIndexByState_TH,
      GeoCountryIso2.TJ => kGeoCityIndexByState_TJ,
      GeoCountryIso2.TL => kGeoCityIndexByState_TL,
      GeoCountryIso2.TM => kGeoCityIndexByState_TM,
      GeoCountryIso2.TN => kGeoCityIndexByState_TN,
      GeoCountryIso2.TO => kGeoCityIndexByState_TO,
      GeoCountryIso2.TR => kGeoCityIndexByState_TR,
      GeoCountryIso2.TT => kGeoCityIndexByState_TT,
      GeoCountryIso2.TV => kGeoCityIndexByState_TV,
      GeoCountryIso2.TW => kGeoCityIndexByState_TW,
      GeoCountryIso2.TZ => kGeoCityIndexByState_TZ,
      GeoCountryIso2.UA => kGeoCityIndexByState_UA,
      GeoCountryIso2.UG => kGeoCityIndexByState_UG,
      GeoCountryIso2.US => kGeoCityIndexByState_US,
      GeoCountryIso2.UY => kGeoCityIndexByState_UY,
      GeoCountryIso2.UZ => kGeoCityIndexByState_UZ,
      GeoCountryIso2.VC => kGeoCityIndexByState_VC,
      GeoCountryIso2.VE => kGeoCityIndexByState_VE,
      GeoCountryIso2.VN => kGeoCityIndexByState_VN,
      GeoCountryIso2.VU => kGeoCityIndexByState_VU,
      GeoCountryIso2.WS => kGeoCityIndexByState_WS,
      GeoCountryIso2.YE => kGeoCityIndexByState_YE,
      GeoCountryIso2.ZA => kGeoCityIndexByState_ZA,
      GeoCountryIso2.ZM => kGeoCityIndexByState_ZM,
      GeoCountryIso2.ZW => kGeoCityIndexByState_ZW,
    _ => null,
  };
  if (map == null) return null;

  final indices = map[stateId];
  if (indices == null) return null;

  final cities = geoCitiesOfCountry(country);
  return (cities, indices);
}

