  select
    OfertaSolicitacaoId,
    PesoEstimado,
    DataSolicitacao,
    DATETIME(DataSolicitacao, "America/Sao_Paulo") AS DS_BR,
    DataAprovacaoRejeicao,
    DATE(DATETIME(DataSolicitacao, "America/Sao_Paulo")) data_datasolicitacao,
    EXTRACT(HOUR FROM DATETIME(DataSolicitacao, "America/Sao_Paulo")) hora_datasolicitacao,
    DATE_DIFF(DataAprovacaoRejeicao,DataSolicitacao, MINUTE) min_solicit_aprov,
    case
      when le.Tenantid = 751939319345786880 or le.Tenantid = 763293090768334848 then 'LDC'
      when le.Tenantid = 862963288634413056 then 'Amaggi'
      when le.Tenantid = 917515665890439168 or le.Tenantid = 917515665890439168 then 'ALZ'
      when le.Tenantid = 1281511290031890432 or le.Tenantid = 1281511290031890432 then 'ADM'
      when le.TenantId = 1164708545162190848 then 'CARGILL'
    end AS embarcador
  from carguero-dw-prd.stage_plataforma.tbl_oferta_solicitacao_base AS osb
  left join (select distinct ofertaid, LoteTransportadorId from `carguero-dw-prd.stage_plataforma.tbl_oferta_incremental`) AS oi ON oi.ofertaid = osb.ofertaid 
  left join (select distinct LoteEmbarcadorTransportadorId, Tenantid from `carguero-dw-prd.stage_plataforma.tbl_lote_embarcador_transportador`) AS le ON le.LoteEmbarcadorTransportadorId = oi.LoteTransportadorId
  where
    DataAprovacaoRejeicao is not null
    and DataSolicitacao is not null
    and DATE(DATETIME(DataSolicitacao, "America/Sao_Paulo")) >= "2022-01-01"
), b as (
  select
    embarcador,
    data_datasolicitacao,
    hora_datasolicitacao,
    count(*) cnt_viagens_mesmo_horario
  from tbl_solicit_oferta tso
  where tso.embarcador is not null
  group by data_datasolicitacao, hora_datasolicitacao, tso.embarcador
  order by cnt_viagens_mesmo_horario desc