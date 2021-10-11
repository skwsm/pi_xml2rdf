#!/usr/bin/ruby

require 'pp'
require 'optparse'
require 'rexml/document' 

module PI # package insert

  Sections = ["PI_0",    '',    #
              "PI_1",    'Warnings', #1. 警告 Warnings
              "PI_2",    'ContraIndications', #2. 禁忌 ContraIndications
              "PI_3",    'CompositionAndProperty', #3. 組成・性状
              "PI_3_1",  'Composition', #3.1. 組成  
              "PI_3_2",  'Property', #3.2 製剤の性状 
              "PI_4",    'IndicationsOrEfficacy', #4 効能又は効果
              "PI_5",    'EfficacyRelatedPrecautions', #5 効能又は効果に関連する注意
              "PI_6",    'InfoDoseAdmin', #6 用法及び用量
              "PI_7",    'InfoPrecautionsDosage', #7 用法及び用量に関連する注意
              "PI_8",    'ImportantPrecautions', #8 重要な基本的注意
              "PI_9",    'UseInSpecificPopulations', #9 特定の背景を有する患者に関する注意
              "PI_9_1",  'UseInPatientsWithComplicationsOrHistoryOfDiseasesEtc', #9.1 合併症・既往歴等のある患者
              "PI_9_2",  'PatientsWithRenalImpairment', #9.2 腎機能障害患者
              "PI_9_3",  'PatientsWithHepaticImpairment', #9.3 肝機能障害患者
              "PI_9_4",  'MalesAndFemalesOfReproductivePotential', #9.4 生殖能を有する者
              "PI_9_5",  'UseInPregnant', #9.5 妊婦
              "PI_9_6",  'UseInNursing', #9.6 授乳婦
              "PI_9_7",  'PediatricUse', #9.7 小児等
              "PI_9_8",  'UseInTheElderly', #9.8 高齢者
              "PI_10",   'Interactions', #10 相互作用
              "PI_10_1", 'ContraIndicatedCombinations', #10.1 併用禁忌(併用しないこと) 
              "PI_10_2", 'PrecautionsForCombinations', #10.2 併用注意(併用に注意すること)
              "PI_11",   'AdverseEvents', #11. 副作用
              "PI_11_1", 'SeriousAdverseEvents', #11.1 重大な副作用
              "PI_11_2", 'OtherAdverseEvents', #11.2 その他の副作用
              "PI_12",   'InfluenceOnLaboratoryValues', #12 臨床検査結果に及ぼす影響
              "PI_13",   'OverDosage', #13 過量投与 
              "PI_14",   'PrecautionsForApplication', #14 適用上の注意 
              "PI_15",   'OtherPrecautions', #15 その他の注意  
              "PI_15_1", 'InformationBasedOnClinicalUse', #15.1 臨床使用に基づく情報
              "PI_15_2", 'InformationBasedOnNonclinicalStudies', #15.2 非臨床試験に基づく情報
              "PI_16",   'Pharmacokinetics', #16 薬物動態
              "PI_16_1", 'BloodLevel', #16.1 血中濃度
              "PI_16_2", 'Absorption', #16.2 吸収
              "PI_16_3", 'Distribution', #16.3 分布
              "PI_16_4", 'Metabolism', #16.4 代謝
              "PI_16_5", 'Excretion', #16.5 排泄
              "PI_16_6", 'SpecificPopulation', #16.6 特定の背景を有する患者
              "PI_16_7", 'DrugAndDrugInteractions', #16.7 薬物相互作用
              "PI_16_8", 'PharmacokineticsEtc', #16.8 その他
              "PI_17",   'ResultsOfClinicalTrials', #17. 臨床成績 
              "PI_17_1", 'EfficacyAndSafety', #17.1 有効性及び安全性に関する試験
              "PI_17_2", 'PostMarketingSurveylancesEtc', #17.2 製造販売後調査等
              "PI_17_3", 'ResultsOfClinicalTrialsEtc', #17.3 その他
              "PI_18",   'EfficacyPharmacology', #18. 薬効薬理
              "PI_18_1", 'MechanismOfAction', #
              "PI_19",   'PhyschemOfActIngredients', #19. 有効成分に関する理化学的知見
              "PI_20",   'PrecautionsForHandling', #20. 取扱い上の注意
              "PI_21",   'ConditionsOfApproval', #21. 承認条件
              "PI_22",   'Package', #22. 包装
              "PI_23",   'MainLiterature', #23. 主要文献
              "PI_24",   'AddresseeOfLiteratureRequest', #24. 文献請求先及び問い合わせ先
              "PI_25",   'AttentionOfInsurance', #25. 保険給付上の注意
              "PI_26",   'NameAddressManufact', #26. 製造販売業者等
             ]

  def sections
    Hash[*Sections]
  end

  Prefixes = {
    "rdf:" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs:" => "http://www.w3.org/2000/01/rdf-schema#",
    "skos:" => "http://www.w3.org/2004/02/skos/core#",
    "dct:" => "http://purl.org/dc/terms/",
    "pi_root:" => "http://med2rdf.org/pi/",
    "pio:" => "http://med2rdf.org/ontology/pio/",
    "bibo:" => "http://purl.org/ontology/bibo/",
    "xsd:" => "http://www.w3.org/2001/XMLSchema#"
  }

  def prefixes
    n3 = []
    Prefixes.each do |pfx, uri|
      n3 << triple("@prefix", pfx, "<#{uri}>")
    end
    n3 << "\n"
    n3
  end

  def triple(s, p, o)
    "#{s} #{p} #{o} .\n" unless o == nil
  end

  def t(path)
    unless @xml.elements[path] == nil
      if @xml.elements[path].has_elements?
        element = @xml.elements[path].text
        "\"#{$1}\""
      else
        "\"#{@xml.elements[path].text}\""
      end
    else
      nil
    end
  end

  module_function :prefixes, :triple, :t, :sections


  class RDF

    include PI

    def initialize(file_path)
      File.open(file_path) do |file|
	@xml = REXML::Document.new(file)
      end
      @pino = "#{set_company_id}_#{set_pi_no}"
      STDERR.print "PI no: #{@pino}\n" if $DEBUG
      @n3 = []
      @sections = Hash[*Sections]
    end
    attr_reader :xml, :pino, :n3, :pi, :sections

    def set_pi_no
      return @xml.elements['PackIns/PackageInsertNo'].text
    end

    def set_company_id
      return @xml.elements['PackIns/CompanyIdentifier'].text
    end

    def symbol(e)
      if e.respond_to?(:name)
        return e.name.to_snake.to_sym
      else
        raise StandardError.new("object does not respond 'name' method")
      end
    end

    def rdf
      @n3 = @n3 + prefixes
      @n3 << triple("@prefix", "pi:", "<#{Prefixes["pi_root:"]}#{pino}#>")
      @n3 << "\n"
      
      general =  General.new(@xml, @pino)
      @n3 = @n3 + general.rdf

      warnings = Warnings.new(@xml, @pino)
      @n3 = @n3 + warnings.rdf

      contra_indications = ContraIndications.new(@xml, @pino)
      @n3 = @n3 + contra_indications.rdf

      composition_and_property = CompositionAndProperty.new(@xml, @pino)
      @n3 = @n3 + composition_and_property.rdf

      indications_of_efficacy = IndicationsOrEfficacy.new(@xml, @pino)
      @n3 = @n3 + indications_of_efficacy.rdf

      efficacy_related_precautions = EfficacyRelatedPrecautions.new(@xml, @pino)
      @n3 = @n3 + efficacy_related_precautions.rdf

      info_dose_admin = InfoDoseAdmin.new(@xml, @pino)
      @n3 = @n3 + info_dose_admin.rdf

      info_precautions_dosage = InfoPrecautionsDosage.new(@xml, @pino)
      @n3 = @n3 + info_precautions_dosage.rdf

      important_precautions = ImportantPrecautions.new(@xml, @pino)
      @n3 = @n3 + important_precautions.rdf

      use_in_populations = UseInSpecificPopulations.new(@xml, @pino)
      @n3 = @n3 + use_in_populations.rdf

      interaction = Interaction.new(@xml, @pino)
      @n3 = @n3 + interaction.rdf

      adverse_events = AdverseEvents.new(@xml, @pino)
      @n3 = @n3 + adverse_events.rdf

      influence_on_laboratory_values = InfluenceOnLaboratoryValues.new(@xml, @pino)
      @n3 = @n3 + influence_on_laboratory_values.rdf

      over_dosage = OverDosage.new(@xml, @pino)
      @n3 = @n3 + over_dosage.rdf

      precautions_for_application = PrecautionsForApplication.new(@xml, @pino)
      @n3 = @n3 + precautions_for_application.rdf

      other_precautions = OtherPrecautions.new(@xml, @pino)
      @n3 = @n3 + other_precautions.rdf

      pharmacokinetics = Pharmacokinetics.new(@xml, @pino)
      @n3 = @n3 + pharmacokinetics.rdf

      results_of_clinical_trials = ResultsOfClinicalTrials.new(@xml, @pino)
      @n3 = @n3 + results_of_clinical_trials.rdf

      efficacy_pharmacology = EfficacyPharmacology.new(@xml, @pino)
      @n3 = @n3 + efficacy_pharmacology.rdf

      physchem_of_act_ingredients = PhyschemOfActIngredients.new(@xml, @pino)
      @n3 = @n3 + physchem_of_act_ingredients.rdf

      precautions_for_handling = PrecautionsForHandling.new(@xml, @pino)
      @n3 = @n3 + precautions_for_handling.rdf

      conditions_of_approval = ConditionsOfApproval.new(@xml, @pino)
      @n3 = @n3 + conditions_of_approval.rdf

      package = Package.new(@xml, @pino)
      @n3 = @n3 + package.rdf

      main_literature = MainLiterature.new(@xml, @pino)
      @n3 = @n3 + main_literature.rdf

      addressee_of_literature_request = AddresseeOfLiteratureRequest.new(@xml, @pino)
      @n3 = @n3 + addressee_of_literature_request.rdf

      attention_of_insurance = AttentionOfInsurance.new(@xml, @pino)
      @n3 = @n3 + attention_of_insurance.rdf

      name_address_manufact = NameAddressManufact.new(@xml, @pino)
      @n3 = @n3 + name_address_manufact.rdf


      @n3.each do |e|
	print "#{e}"
      end
    end

    def simple_list(e) # List of items
      list = []
      e.each_element do |elm|
	list << item(elm)
      end
      list
    end

    def ordered_list(e) # List of items
      list = []
      e.each_element do |elm|
        list << item(elm)
      end
      list
    end

    def unordered_list(e)
      list = []
      e.each_element do |elm|
        list << item(elm)
      end
      list
    end

    def item(e)
      items = {}
      e.each_element do |elm|
        # m is Header, Detail, OrderedList, UnorderedList, SimpleList, TblBlock, or Graphic
	m = elm.name.to_snake.to_sym
	if items.key?(m)
	  items[m] << send(m, elm)
	else
	  items[m] = [send(m, elm)]
	end
      end
      items
    end

    def header(e)
      cdata_content_type(e)
    end

    def detail(e) 
      details = []
      e.each_element do |elm|
	details << lang(elm)
      end
#      details[:id] = e.attribute("id")
#      details[:modified] = e.attribute("modified")
      details
    end

    def lang(e)
      langs = {}
      langs[:text] = e.texts.map{|t| t.to_s.gsub("\n", "")}.join(" ")
      langs[:attr] = {:lang => e.attribute("xml:lang")}
      if e.has_elements?
	e.each_element do |elm|
#	  m = elm.name.to_snake.to_sym
	  m = symbol(elm)
          case m
          when :header_ref
	  #HeaderRef を想定
	    langs[:attr].merge!(header_ref(elm))
          when :inline_graphic
	    langs[:attr].merge!(inline_graphic(elm))
          else
          end
	end
      end
      langs
    end

    def header_ref(e)
      h = {}
      e.attributes.each_key do |key|
	h[key.to_snake.to_sym] = e[key]
      end
      h
    end

    def inline_graphic(e)
      h = {}
      e.attributes.each_key do |key|
	h[key.to_snake.to_sym] = e[key]
      end
      h
    end

    def various_forms_wo_id_type(e) # For VariousFormsWithoutID-TYPE
      h = {}
      e.each_element do |elm|
	m = elm.name.to_snake.to_sym
        if h.key?(m)
	  h[m] << send(m, elm)
        else
	  h[m] = [send(m, elm)]
        end
      end
      h 
    end

    def various_forms_wo_id_type_rdf(h, subj)
      n3 = []
      h.each do |k, v|
        case k
        when :detail
          v.each do |elm|
            n3 << triple(subj, "dct:description", "\"#{elm[0][:text]}\"@ja")
          end
        when :simple_list
          i = 0
          v.each do |elm|
            elm.each do |elm_h|
              elm_h.each do |elm_k, elm_v|
                case elm_k
                when :header
                  i += 1
                  n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
                  n3 << triple("#{subj}.item#{i}", "rdfs:label", "\"#{elm_v[0][0][:lang][:text]}\"@ja")
                when :detail
                  n3 << triple("#{subj}.item#{i}", "dct:description", "\"#{elm_v[0][0][:text]}\"@ja")
                else
                end
              end
            end
          end
        when :ordered_list, :unordered_list
          v.each do |elm|
            elm.each.with_index(1) do |elm_e, i|
              n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
              elm_e.each do |elm_e_k, elm_e_v|
                case elm_e_k
                when :header
                  n3 << triple("#{subj}.item#{i}", "rdfs:title", "\"#{elm_e_v[0][0][:lang][:text]}\"@ja")
                when :detail
                  elm_e_v.each do |elm_e_v_e|
                    n3 << triple("#{subj}.item#{i}", "dct:description", "\"#{elm_e_v_e[0][:text]}\"@ja")
                  end
                when :tbl_block
                  elm_e_v.each.with_index(1) do |elm_e_v_e, j|
                    n3 << triple(subj, "pio:table", "#{subj}.item#{i}.table#{j}")
                    redundant_table = make_redundant_table(elm_e_v_e)
                    redundant_table[:simple_table].each.with_index(1) do |row, k|
                      n3 << triple("#{subj}.item#{i}.table#{j}", "pio:row", "#{subj}.item#{i}.table#{j}.row#{k}")
                      row.each.with_index(1) do |col, l|
                        n3 << triple("#{subj}.item#{i}.table#{j}.row#{k}", "pio:column", "#{subj}.item#{i}.table#{j}.row#{k}.column#{l}")
                        n3 << triple("#{subj}.item#{i}.table#{j}.row#{k}.column#{l}", "rdf:value", "\"#{col}\"")
            
                      end
                    end
                  end
                when :ordered_list || :unordered_list
                  elm_e_v.each do |elm_e_v_e|
                    elm_e_v_e.each.with_index(1) do |elm_e_v_e_e, m|
                      n3 << triple(subj, "pio:section", "#{subj}.item#{i}.item#{m}")
                      elm_e_v_e_e.each do |elm_e_v_e_e_k, elm_e_v_e_e_v|
                        case elm_e_v_e_e_k
                        when :header
                          n3 << triple("#{subj}.item#{i}", "rdfs:title", "\"#{elm_e_v_e_e_v[0][0][:lang][:text]}\"@ja")
                        when :detail
                          elm_e_v_e_e_v.each do |elm_e_v_e_e_v_e|
                            n3 << triple("#{subj}.item#{i}", "dct:description", "\"#{elm_e_v_e_e_v_e[0][:text]}\"@ja")
                          end
                        when :tbl_block
                          elm_e_v_e_e_v.each.with_index(1) do |elm_e_v_e_e_v_e, n|
                            n3 << triple(subj, "pio:table", "#{subj}.item#{i}.item#{m}.table#{n}")
                            redundant_table_2 = make_redundant_table(elm_e_v_e_e_v_e)
                            redundant_table_2[:simple_table].each.with_index(1) do |row2, ni|
                              n3 << triple("#{subj}.item#{i}.item#{m}.table#{n}", "pio:row", "#{subj}.item#{i}.item#{m}.table#{n}.row#{ni}")
                              row2.each.with_index(1) do |col2, nj|
                                n3 << triple("#{subj}.item#{i}.item#{m}.table#{n}.row#{ni}", "pio:column", "#{subj}.item#{i}.item#{m}.table#{n}.row#{ni}.column#{nj}")
                                n3 << triple("#{subj}.item#{i}.item#{m}.table#{n}.row#{ni}.column#{nj}", "rdf:value", "\"#{col2}\"")
                              end
                            end
                          end
                        else
                        end
                      end
                    end
                  end 
                else
                end
              end
            end
          end
        else
        end
      end
      n3
    end

    def various_forms_type(e) # For VariousForms-TYPE
      h = {}
      e.each_element do |elm|
        # m is Detail, OrderedList, UnorderedList, SimpleList, TblBlock, or Graphic
	m = elm.name.to_snake.to_sym
        if h.key?(m)
	  h[m] << send(m, elm)
        else
	  h[m] = [send(m, elm)]
        end
      end
#      h[:category_ref] = e.attribute(:categoryRef).to_s.split("id")[0]
#      h[:frequency_ref] = e.attribute(:frequencyRef).to_s.split("id")[0]
      h
    end

    def various_forms_type_rdf(h, subj)
      n3 = []
      h.each do |k, v|
        case k
        when :detail
          v.each do |elm|
            n3 << triple(subj, "dct:description", "\"#{elm[0][:text]}\"@ja")
          end
        when :simple_list
          i = 0
          v.each do |elm|
            elm.each do |elm_h|
              elm_h.each do |elm_k, elm_v|
                case elm_k
                when :header
                  i += 1
                  n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
                  n3 << triple("#{subj}.item#{i}", "rdfs:label", "\"#{elm_v[0][0][:lang][:text]}\"@ja")
                when :detail
                  n3 << triple("#{subj}.item#{i}", "dct:description", "\"#{elm_v[0][0][:text]}\"@ja")
                else
                end
              end
            end
          end

        when :ordered_list, :unordered_list
          v.each do |elm|
            elm.each.with_index(1) do |elm_e, i|
              n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
              elm_e.each do |elm_e_k, elm_e_v|
                case elm_e_k
                when :header
                  n3 << triple("#{subj}.item#{i}", "rdfs:title", "\"#{elm_e_v[0][0][:lang][:text]}\"@ja")
                when :detail
                  elm_e_v.each do |elm_e_v_e|
                    n3 << triple("#{subj}.item#{i}", "dct:description", "\"#{elm_e_v_e[0][:text]}\"@ja")
                  end
                when :tbl_block
#                   p elm_e_v
                else
                end
              end
            end
          end
        else
        end
      end
      n3
    end

    def various_forms_with_id_required_type(e) # VariousFormsWithIDrequired-TYPE
      h = {}
      e.each_element do |elm|
        # m is Detail, OrderedList, UnorderedList, SimpleList, TblBlock, or Graphic
        m = elm.name.to_snake.to_sym
        if h.key?(m)
          h[m] << send(m, elm)
        else
          h[m] = [send(m, elm)]
        end
      end
      h[:id] = e.attribute(:id).to_s.split("id")[0]
      h
    end

    def cdata_content_type(e)
      a = []
      e.each_element do |elm|
#	m = elm.name.to_snake.to_sym
	m = symbol(elm)
        a << {m => send(m, elm)}
#	h[m] = send(m, elm)
      end
      a
    end

    def tbl_block(e)
      h = {}
      e.each_element do |elm|
#	m = elm.name.to_snake.to_sym
	m = symbol(elm)
	h[m] = send(m, elm)
      end
      h[:rows] = get_number_of_rows(h)
      h[:cols] = get_number_of_cols(h)
      h
    end

    def get_number_of_rows(h)
      h[:simple_table].size
    end

    def get_number_of_cols(h)
      number_of_cols = 0
      h[:simple_table][0].each do |cell|
        if cell.key?(:cspan)
          number_of_cols += cell[:cspan].to_i
        else
          number_of_cols += 1
        end
      end
      number_of_cols
    end

    def make_redundant_table(h)
#      pp h
      table = {}
      table[:simple_table] = Array.new(h[:rows]).map{Array.new(h[:cols]){nil}}
      table[:width_definition] = h[:width_definition]
      table[:tbl_caption] = h[:tbl_caption]
      table[:original_table] = h[:simple_table]
      (0..h[:rows] - 1).each do |i|
        offset = 0
        (0..h[:cols] - 1).each do |j|
#          pp table[:simple_table]
#          STDERR.print "i: #{i}, j: #{j}, offset: #{offset}\n"
          if table[:simple_table][i][j] == nil
            unless table[:original_table][i][j - offset] == nil
              if table[:original_table][i][j - offset].key?(:rspan) && 
                table[:original_table][i][j - offset].key?(:cspan)
                rspan = table[:original_table][i][j - offset][:rspan].to_i
                cspan = table[:original_table][i][j - offset][:cspan].to_i
                (0..rspan - 1).each do |idx_i|
                  (0..cspan - 1).each do |idx_j|
                     table[:simple_table][i + idx_i][j + idx_j] = cell_text(table[:original_table][i][j - offset])
#                    if table[:original_table][i][j - offset].key?(:unordered_list)
#                      table[:simple_table][i + idx_i][j + idx_j] 
#                        = merge_list_items(table[:original_table][i][j - offset][:unordered_list]
#                    else
#                      table[:simple_table][i + idx_i][j + idx_j] = table[:original_table][i][j - offset][:detail][0][:text]
#                    end
                  end
                end

              elsif table[:original_table][i][j - offset].key?(:rspan)
                rspan = table[:original_table][i][j - offset][:rspan].to_i
                (0..rspan - 1).each do |idx|
                  table[:simple_table][i + idx][j] = cell_text(table[:original_table][i][j - offset])
#                  table[:simple_table][i + idx][j] = table[:original_table][i][j - offset][:detail][0][:text]
                end
              elsif table[:original_table][i][j - offset].key?(:cspan)
                cspan = table[:original_table][i][j - offset][:cspan].to_i
                (0..cspan - 1).each do |idx|
                  table[:simple_table][i][j + idx] = cell_text(table[:original_table][i][j - offset])
#                  table[:simple_table][i][j + idx] = table[:original_table][i][j - offset][:detail][0][:text]
                end
              else
                table[:simple_table][i][j] = cell_text(table[:original_table][i][j - offset])
#                table[:simple_table][i][j] = table[:original_table][i][j - offset][:detail][0][:text]
              end
            end
          else
            offset += 1  
          end
        end
      end
      table
    end

    def cell_text(h)
      if h.key?(:unordered_list)
        merge_list_items(h[:unordered_list])
      else
        h[:detail][0][:text]
      end
    end

    def merge_list_items(a)
      tmp_list = []
      a.each do |item|
        tmp_list << item[:detail][0][0][:text]
      end
      tmp_list.join("\n")
    end

    def simple_table(e)
      a = []
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        a << send(m, elm)
      end
      a
    end

    def simp_tbl_row(e)
      a = []
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        a << send(m, elm)
      end
      a
    end

    def simp_tbl_cell(e)
      h = {}
      e.attributes.each do |attr|
        unless (attr[0] == "rspan" && attr[1] == "1") || 
               (attr[0] == "cspan" && attr[1] == "1") 
          h[attr[0].to_snake.to_sym] = attr[1]
        end
      end
      if e.has_elements?
        e.each_element do |elm|
          m = elm.name.to_snake.to_sym
          h[m] = send(m, elm)
        end
      else # for empty cell
        h[:detail] = [{:text => ""}]
      end
      h
    end

    def tbl_caption(e)
      h = {}
      h
    end

    def simp_tbl_foot(e)
      a = []
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        a << send(m, elm)
      end
      a
    end

    def graphic(e)
      a = []
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        case m
        when :graphic_caption
          a << send(m, elm)
        when :graphic_body
          a << graphic_body(elm)
        else
        end
      end
      a
    end

    def graphic_caption(e)
      cdata_content_type(e)
    end

    def graphic_body(e)
      h = {}
      e.attributes.each_key do |k|
        h[k] = e.attributes[k]
      end
      h
    end

    def width_definition(e)
      h = {}
      e.each_element do |elm|
      end
      h
    end

    def other_information(e)
      h = {}
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        h[m] = send(m, elm)
      end
      h
    end

    def other_information_rdf(h, subj, i)
      n3 = []
      item_cnt = i
      h.each do |k, v|
        case k
        when :header
          item_cnt += 1
          n3 << triple(subj, "pio:section", "#{subj}.item#{item_cnt}")
          n3 << triple("#{subj}.item#{item_cnt}", "rdfs:label", "\"#{v[0][:lang][:text]}\"@ja")
        when :detail
          n3 << triple("#{subj}.item#{item_cnt}", "dct:description", "\"#{v[0][:text]}\"@ja")
        when :ordered_list || :unordered_list
          item_cnt_2 = 0
          v.each do |elm|
            elm.each do |elm_k, elm_v|
              item_cnt_2 += 1
              n3 << triple("#{subj}.item#{item_cnt}", "pio:section", "#{subj}.item#{item_cnt}.item#{item_cnt_2}")
              case elm_k
              when :header
#                n3 << triple("#{subj}.item#{item_cnt}.item#{item_cnt_2}", "rdfs:label", "\"#{elm_v[0][:lang][:text]}\"@ja")
                n3 << triple("#{subj}.item#{item_cnt}.item#{item_cnt_2}", "rdfs:label", "\"#{elm_v[0][0][:lang][:text]}\"@ja")
              when :detail
# add header
                n3 << triple("#{subj}.item#{item_cnt}.item#{item_cnt_2}", "dct:desctiption", "\"#{elm_v[0][0][:text]}\"@ja")
              else
              end
            end 
          end
        else
        end
      end
      n3
    end
  end

## General

  class General < RDF

    include PI

    def initialize(xml, pino)
      @xml = xml
      @pino = pino
      @n3 = []
    end
    attr_accessor :xml, :pino, :n3

    def rdf
      pi_sections
      general_info
    end

    def pi_sections
      Hash[*Sections].keys.each do |section|
        @n3 << triple("pi_root:#{@pino}", "pio:section", "pi:#{section}")
      end
    end

    def general_info
      @n3 << triple("pi_root:#{@pino}", "dct:identifier", "\"#{@pino}\"") 
      @n3 << triple("pi_root:#{@pino}", "pio:company_identifier", t('PackIns/CompanyIdentifier'))
      @n3 << triple("pi_root:#{@pino}", "pio:date_of_preparation_or_revision",
                    "#{t('PackIns/DateOfPreparationOrRevision/PreparationOrRevision/YearMonth')}^^xsd:date")

      @n3 << triple("pi_root:#{@pino}", "pio:version", 
                    t('PackIns/DateOfPreparationOrRevision/PreparationOrRevision/Version/Lang'))

      @n3 << triple("pi_root:#{@pino}", "pio:sccj_no", t('PackIns/Sccj/SccjNo'))
      @n3 << triple("pi_root:#{@pino}", "pio:therapeutic_classification",
                    t('//TherapeuticClassification/Detail/Lang'))

      @n3 << triple("pi_root:#{@pino}", "pio:approval_brand_name",
                    t('//ApprovalEtc/DetailBrandName/ApprovalBrandName/Lang'))
      @n3 << triple("pi_root:#{@pino}", "pio:yj_code",
                    t('//ApprovalEtc/DetailBrandName/BrandCode/YJCode'))

      @n3 << triple("pi_root:#{@pino}", "pio:trademark_name",
                    t('//DetailBrandName/TrademarkInEnglish/TrademarkName'))

      @n3 << triple("pi_root:#{@pino}", "pio:name_in_hiragana", 
                    t('//DetailBrandName/BrandNameInHiragana/NameInHiragana'))
      @n3 << triple("pi_root:#{@pino}", "pio:approval_no",
                    t('//DetailBrandName/ApprovalAndLicenseNo/ApprovalNo'))
      @n3 << triple("pi_root:#{@pino}", "pio:license_no",
                    t('//DetailBrandName/ApprovalAndLicenseNo/LicenseNo'))
      @n3 << triple("pi_root:#{@pino}", "pio:starting_date_of_marketing",
                    "#{t('//DetailBrandName/StartingDateOfMarketing')}^^xsd:date")
      @n3 << triple("pi_root:#{@pino}", "pio:storage_method",
                    t('//DetailBrandName/Storage/StorageMethod/Lang'))
      @n3 << triple("pi_root:#{@pino}", "pio:shelf_life",
                    t('//DetailBrandName/Storage/ShelfLife/Lang'))

      @n3
    end
  end

## Warnings

  class Warnings < RDF

    include PI

    def initialize(xml, pino, section = 'PI_1')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @s = PI.sections
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj, :s

    def rdf
      section_elm  = @xml.elements["//#{s[section]}"]
      unless section_elm == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(section_elm), subj)
      end
      @n3
    end
  end

## ContraIndications

  class ContraIndications < RDF

    include PI

    def initialize(xml, pino, section = 'PI_2')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @s = PI.sections
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj, :s

    def rdf
      section_elm = @xml.elements["//#{s[section]}"]
      unless section_elm == nil
        @n3 << triple(@subj, "a", "pio:#{section}")
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(section_elm), subj)
      end
      @n3
    end
  end

  class CompositionAndProperty < RDF

    include PI

    def initialize(xml, pino, section = 'PI_3')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @s = PI.sections
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj, :s

    def rdf
      section_elm = @xml.elements["//#{s[section]}"]
      unless section_elm == nil
        @n3 << triple(@subj, "a", "pio:#{section}")
        section_elm.each_element do |elm|
          m = symbol(elm)
          case m
          when :overview_of_recipe
#            overview_of_recipe(e)
          when :composition
            composition_rdf(composition(elm))
          when :property
            property_rdf(property(elm))
          else
          end
        end
      end
      @n3
    end

    def overview_of_recipe(e)
      cdata_content_type(e)
    end

    def composition(e)
      h = {}
      h[:composition_for_brand] = []
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :overview_of_composition
          h[:overview_of_composition] = overview_of_composition(elm)
        when :composition_for_brand
          h[:composition_for_brand] << composition_for_brand(elm)
        when :composition_comments
          h[:composition_comments] = composition_comments(elm)
        else
        end
      end
      h
    end

    def composition_rdf(e)
      subj = "pi:PI_3_1"
      i = 1
#      @n3 << triple(subj, "a", "pio:PI_3_1") 
      e.each do |k, v|
        if k == :composition_for_brand
          @n3 << triple(subj, "pio:composition_for_brand", "#{subj}.item#{i}")
          v.each do |elm|
            contained_amount = elm[:composition_for_constituent_units][0][:composition_table][0][:contained_amount][0]
            @n3 << triple("#{subj}.item#{i}", "pio:contained_amount", "#{subj}.item#{i}.contained_amount")
            if contained_amount.key?(:active_ingredient_name)
              @n3 << triple("#{subj}.item#{i}.contained_amount", "pio:active_ingredient_name", 
                            "\"#{contained_amount[:active_ingredient_name][0][:lang][:text]}\"@ja")
            end
            if contained_amount.key?(:value_and_unit)
              @n3 << triple("#{subj}.item#{i}.contained_amount", "pio:value_and_unit", 
                            "\"#{contained_amount[:value_and_unit][0][:lang][:text]}\"@ja")
            end
            if contained_amount.key?(:active_ingredient_additional_info)
              @n3 << triple("#{subj}.item#{i}.contained_amount", "pio:active_ingredient_additional_info", 
                            "#{subj}.item#{i}.active_ingredient_additional_info")
              if contained_amount[:active_ingredient_additional_info].key?(:active_ingredient_name)
                @n3 << triple("#{subj}.item#{i}.active_ingredient_additional_info", "pio:active_ingredient_name", 
                              "\"#{contained_amount[:active_ingredient_additional_info][:active_ingredient_name][0][:lang][:text]}\"@ja")
              end
              if contained_amount[:active_ingredient_additional_info].key?(:value_and_unit)
                @n3 << triple("#{subj}.item#{i}.active_ingredient_additional_info", "pio:value_and_unit", 
                              "\"#{contained_amount[:active_ingredient_additional_info][:value_and_unit][0][:lang][:text]}\"@ja")
              end
            end
           
            additives = elm[:composition_for_constituent_units][0][:composition_table][0][:additives] 
            if additives.key?(:list_of_additives)
              @n3 << triple("#{subj}.item#{i}", "pio:additives", "\"#{additives[:list_of_additives][0][:lang][:text]}\"@ja")
              list_of_additives = []
              if /、/ =~ additives[:list_of_additives][0][:lang][:text]
                list_of_additives = additives[:list_of_additives][0][:lang][:text].split("、")
              elsif /　/ =~ additives[:list_of_additives][0][:lang][:text]
                list_of_additives = additives[:list_of_additives][0][:lang][:text].split("　")
              elsif / / =~ additives[:list_of_additives][0][:lang][:text]
                list_of_additives = additives[:list_of_additives][0][:lang][:text].split(" ")
              end
              list_of_additives.each.with_index(1) do |additive, j|
                @n3 << triple("#{subj}.item#{i}", "pio:info_individual_additives", "#{subj}.item#{i}.additive#{j}")
                @n3 << triple("#{subj}.item#{i}.additive#{j}", "pio:additive", "\"#{additive}\"@ja")
              end
            elsif additives.key?(:individual_additives) 
              additives[:individual_additives].each.with_index(1) do |additive, j|
#                @n3 << triple("#{subj}.item#{i}", "pio:info_individual_additives", "#{subj}.item#{i}.item#{j}")
                @n3 << triple("#{subj}.item#{i}", "pio:info_individual_additives", "#{subj}.item#{i}.additive#{j}")
                @n3 << triple("#{subj}.item#{i}.additive#{j}", "pio:additive", "\"#{additive[:individual_additive][0][:lang][:text]}\"@ja")
                if additive.key?(:value_and_unit)
                  @n3 << triple("#{subj}.item#{i}.additive#{j}", "pio:value_and_unit", "\"#{additive[:value_and_unit][0][:lang][:text]}\"@ja")
                end
              end
            else 
            end 
            i += 1
#            @n3 << triple("#{subj}.item#{i}", "a", "pio:PI_3_1")
          end
        elsif k == :composition_comments
          @n3 << triple("#{subj}.item#{i}", "pio:composition_comments", "\"#{v[0][:lang][:text]}\"@ja")
        end
      end
      if e == nil
        @n3 << triple("#{subj}.item#{i}", "a", "pio:PI_3_1")
      end
    end

    def property(e)
      h = {}
      h[:property_for_brand] = []

      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :overview_of_property
          h[:overview_of_property] = overview_of_property(elm)
        when :property_for_brand
          h[:property_for_brand] << property_for_brand(elm)
        else
        end
      end
      h
    end

    def property_rdf(e)
      subj = "pi:PI_3_2"
      i = 0
      @n3 << triple(subj, "a", "pio:PI_3_2")
      e.each do |k, v|
#        @n3 << triple(subj, "pio:", "#{subj}.item#{i}")

        v.each do |elm|
          i += 1
          @n3 << triple(subj, "pio:property_for_brand", "#{subj}.item#{i}")
          property_table = elm[:property_for_constituent_units][0][:property_table][0]
          property_table.keys.each do |key|
            case key
            when :formulation
              @n3 << triple("#{subj}.item#{i}", "pio:formulation", "\"#{property_table[:formulation][0][:lang][:text]}\"")
            when :color_tone
              @n3 << triple("#{subj}.item#{i}", "pio:color_tone", "\"#{property_table[:color_tone][0][:lang][:text]}\"")
            when :size_number
              @n3 << triple("#{subj}.item#{i}", "pio:size_number", "\"#{property_table[:size_number][0][:lang][:text]}\"")
            when :weight
              @n3 << triple("#{subj}.item#{i}", "pio:weight", "\"#{property_table[:weight][0][:lang][:text]}\"")
            when :id_code
              @n3 << triple("#{subj}.item#{i}", "pio:id_code", "\"#{property_table[:id_code][0][:lang][:text]}\"")
            when :ph
              @n3 << triple("#{subj}.item#{i}", "pio:ph", "\"#{property_table[:ph][0][:lang][:text]}\"")
            when :osmotic_ratio
              @n3 << triple("#{subj}.item#{i}", "pio:osmotic_ratio", "\"#{property_table[:osmotic_ratio][0][:lang][:text]}\"")
            when :odor
              @n3 << triple("#{subj}.item#{i}", "pio:odor", "\"#{property_table[:odor][0][:lang][:text]}\"")
            when :taste
              @n3 << triple("#{subj}.item#{i}", "pio:taste", "\"#{property_table[:taste][0][:lang][:text]}\"")
            else
            end
          end

          if property_table.key?(:shape)
          property_table[:shape].keys.each do |shape_key|
            case shape_key
            when :shape_front
              @n3 << triple("#{subj}.item#{i}", "pio:shape_front", "\"#{property_table[:shape][:shape_front][0][:lang][:attr][:gfname]}\"")
            when :shape_back
              @n3 << triple("#{subj}.item#{i}", "pio:shape_back", "\"#{property_table[:shape][:shape_back][0][:lang][:attr][:gfname]}\"")
            when :shape_side
              @n3 << triple("#{subj}.item#{i}", "pio:shape_side", "\"#{property_table[:shape][:shape_side][0][:lang][:attr][:gfname]}\"")
            when :other_shape
              @n3 << triple("#{subj}.item#{i}", "pio:other_shape", "#{subj}.item#{i}.other_shape")
              if property_table[:shape][:other_shape].size > 0 &&
                 property_table[:shape][:other_shape][0].key?(:shape_title)
                @n3 << triple("#{subj}.item#{i}.other_shape", "pio:shape_title", "\"#{property_table[:shape][:other_shape][0][:shape_title]}\"")
              end
              if property_table[:shape][:other_shape].size > 0 &&
                 property_table[:shape][:other_shape][0].key?(:shape_detail)
                @n3 << triple("#{subj}.item#{i}.other_shape", "pio:shape_detail", "\"#{property_table[:shape][:other_shape][0][:shape_detail][0][:lang][:attr][:gfname]}\"")
              end
            else
            end
          end
          end

          if property_table.key?(:size)
          property_table[:size].keys.each do |size_key|
            case size_key
            when :size_diameter
              @n3 << triple("#{subj}.item#{i}", "pio:size_diameter", "\"#{property_table[:size][:size_diameter][0][:lang][:text]}\"")
            when :size_long_diameter
              @n3 << triple("#{subj}.item#{i}", "pio:size_long_diameter", "\"#{property_table[:size][:size_long_diameter][0][:lang][:text]}\"")
            when :size_short_diameter
              @n3 << triple("#{subj}.item#{i}", "pio:size_short_diameter", "\"#{property_table[:size][:size_short_diameter][0][:lang][:text]}\"")
            when :size_total_diameter
              @n3 << triple("#{subj}.item#{i}", "pio:size_total_diameter", "\"#{property_table[:size][:size_total_diameter][0][:lang][:text]}\"")
            when :size_thickness
              @n3 << triple("#{subj}.item#{i}", "pio:size_thickness", "\"#{property_table[:size][:size_thickness][0][:lang][:text]}\"")
            when :size_area
              @n3 << triple("#{subj}.item#{i}", "pio:size_area", "\"#{property_table[:size][:size_area][0][:lang][:text]}\"")
            when :other_size
              @n3 << triple("#{subj}.item#{i}", "pio:other_size", "#{subj}.item#{i}.other_size")
              if property_table[:size][:other_size].size > 0 &&
                 property_table[:size][:other_size][0].key?(:size_title)
                @n3 << triple("#{subj}.item#{i}.other_size", "pio:size_title", "\"#{property_table[:size][:other_size][0][:size_title]}\"")
              end
              if property_table[:size][:other_size].size > 0 &&
                 property_table[:size][:other_size][0].key?(:size_detail)
                @n3 << triple("#{subj}.item#{i}.other_size", "pio:size_detail", "\"#{property_table[:size][:other_size][0][:size_detail]}\"")
              end
            else
            end
            end
          end
        end
      end
    end

    def overview_of_property(e)
      cdata_content_type(e)
    end

    def property_for_brand(e)
      h = {}
      h[:property_for_constituent_units] = []
      e.each_element do |elm|
        h[:property_for_constituent_units] << property_for_constituent_units(elm)
      end
      h
    end

    def overview_of_composition(e)
      cdata_content_type(e)
    end

    def property_for_constituent_units(e)
      h = {}
      h[:property_table] = []
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :constituent_units
          h[:constituent_units] = constituent_units(elm)
        when :property_table
          h[:property_table] << property_table(elm)
        when :comments_for_constituent_units
          h[:comments_for_constituent_units] = comments_for_constituent_units(e)
        else
        end
      end
      h
    end

    def property_table(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :formulation, :color_tone, :size_number, :weight,
             :id_code, :ph, :osmotic_ratio, :odor
          h[m] = cdata_content_type(elm)
        when :shape, :size
          h[m] = send(m, elm)
        when :composition_and_property_tbl_title 
          h[m] = composition_and_property_tbl_title(elm)
        when :composition_and_property_tbl_foot
          h[m] = composition_and_property_tbl_foot(elm)
        else
        end
      end
      h
    end

    def constituent_units(e)
      cdata_content_type(e)
    end

    def shape(e)
      h = {}

      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :shape_front, :shape_back, :shape_side
          h[m] = cdata_content_type(elm)
        when :other_shape
          if h.key?(:other_shape)
            h[m] << other_shape(elm)
          else
            h[:other_shape] = []
          end
        else
        end
      end
      h
    end

    def other_shape(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :shape_title
          h[m] = cdata_content_type(elm)
        when :shape_detail
          h[m] = cdata_content_type(elm)
        else
        end 
      end
      h
    end

    def size(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :size_diameter, :size_long_diameter, :size_short_diameter,
             :size_total_length, :size_thickness, :size_area
          h[m] = cdata_content_type(elm)
        when :other_size
          if h.key?(:other_size)
            h[:other_size] << other_size(elm)
          else
            h[:other_size] = []
          end
        else
        end
      end
      h
    end

    def other_size(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :size_title
          h[m] = cdata_content_type(elm)
        when :size_detail
          h[m] = cdata_content_type(elm)
        else
        end
      end
      h
    end

    def composition_for_brand(e)
      h = {}
      h[:composition_for_constituent_units] = []
      h[:ref] = e.attributes["ref"]
      e.each_element do |elm|
        h[:composition_for_constituent_units] << composition_for_constituent_units(elm)
      end
      h
    end

    def composition_comments(e)
      cdata_content_type(e)
    end

    def composition_for_constituent_units(e)
      h = {}
      h[:composition_table] = []
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :constituent_units
          h[:constituent_units] = constituent_units(elm)
        when :composition_table
          h[:composition_table] << composition_table(elm)
        when :comments_for_constituent_units
          h[:comments_for_constituent_units] = comments_for_constituent_units(elm)
        else
        end
      end
      h
    end

    def constituent_units(e)
      cdata_content_type(e) 
    end

    def composition_table(e)
      h = {}
      h[:contained_amount] = []
      h[:other_composition] = []
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :composition_and_property_tbl_title
          h[m] = send(m, elm)
        when :contained_amount
          h[m] << send(m, elm)
        when :additives
          h[m] = send(m, elm)
        when :other_composition
          h[m] << send(m, elm)
        when :composition_and_property_tbl_foot
          h[m] = send(m, elm)
        else
        end
      end
      h
    end

    def comments_for_constituent_units(e)
      cdata_content_type(e)
    end

    def composition_and_property_tbl_title(e)
      cdata_content_type(e)
    end

    def contained_amount(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :active_ingredient_name
          h[:active_ingredient_name] = active_ingredient_name(elm)
        when :value_and_unit
          h[:value_and_unit] = value_and_unit(elm)
        when :active_ingredient_additional_info
          h[:active_ingredient_additional_info] = active_ingredient_additional_info(elm)
        else
        end
      end
      h
    end

    def active_ingredient_name(e)
      cdata_content_type(e)
    end

    def active_ingredient_additional_info(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :active_ingredient_name
          h[:active_ingredient_name] = active_ingredient_name(elm)
        when :value_and_unit
          h[:value_and_unit] = value_and_unit(elm)
        else
        end
      end
      h  
    end

    def additives(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :list_of_additives
          h[:list_of_additives] = list_of_additives(elm)
        when :individual_additives
          h[:individual_additives] = individual_additives(elm)
        else
        end
      end
      h
    end

    def other_composition(e)
      h = {}
      h[:content] = []
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :category_name
          h[:category_name] = category_name(elm)
        when :content
          h[:content] << content(elm)
        else
        end
      end
      h
    end

    def category_name(e)
      cdata_content_type(e)
    end

    def content(e)
      h = {}
      h[:content_title] = content_title(e)
      h[:content_detail]  = content_detail(e)
      h
    end
 
    def content_title(e)
      cdata_content_type(e)
    end

    def content_detail(e)
      cdata_content_type(e)
    end

    def composition_and_property_tbl_foot(e)
      cdata_content_type(e)
    end

    def list_of_additives(e)
      cdata_content_type(e)
    end

    def individual_additives(e)
      a = []
      e.each_element do |elm|
        a << info_individual_additive(elm)
      end
      a
    end

    def info_individual_additive(e)
      h = {}
      e.each_element do |elm|
        m = symbol(elm)
        case m
        when :individual_additive
          h[:individual_additive] = individual_additive(elm)
        when :value_and_unit
          h[:value_and_unit] = value_and_unit(elm)
        else
        end
      end
      h
    end

    def individual_additive(e)
      cdata_content_type(e)
    end

    def value_and_unit(e) 
      cdata_content_type(e)
    end
  end

## IndicationsOrEfficacy

  class IndicationsOrEfficacy < RDF

    include PI

    def initialize(xml, pino, section = 'PI_4')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @s = PI.sections
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj, :s

    def rdf
      section_elm = @xml.elements["//#{s[section]}"]
      unless section_elm == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        case section_elm.attributes["wordingPatternOfIndications"]
        when '1'
          @n3 << triple(subj, 'dct:title', '"効能又は効果"@ja')
        when '2'
          @n3 << triple(subj, 'dct:title', '"効能効果"@ja')
        when '3'
          @n3 << triple(subj, 'dct:title', '"効能・効果"@ja')
        else
        end
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(section_elm), subj)
      end
      @n3
    end
  end


##5   効能又は効果に関連する注意 EfficacyRelatedPrecautions

  class EfficacyRelatedPrecautions < RDF

    include PI
    def initialize(xml, pino, section = 'PI_5')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//EfficacyRelatedPrecautions'] == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        case @xml.elements['//EfficacyRelatedPrecautions'].attributes["wordingPatternOfEfficacyRelatedPrecautions"]
        when '1'
          @n3 << triple(subj, 'dct:title', '"効能又は効果に関連する注意"@ja')
        when '2'
          @n3 << triple(subj, 'dct:title', '"効能効果に関連する注意"@ja')
        when '3'
          @n3 << triple(subj, 'dct:title', '"効能・効果に関連する注意"@ja')
        else
        end
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//EfficacyRelatedPrecautions']), subj)
      end
      @n3
    end

  end

  class InfoDoseAdmin < RDF

    def initialize(xml, pino, section = 'PI_6')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//InfoDoseAdmin'] == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        case @xml.elements['//InfoDoseAdmin'].attributes["wordingPatternOfDoseAdmin"]
        when '1'
          @n3 << triple(subj, 'dct:title', '"用法及び用量"@ja')
        when '2'
          @n3 << triple(subj, 'dct:title', '"用法用量"@ja')
        when '3'
          @n3 << triple(subj, 'dct:title', '"用法・用量"@ja')
        else
        end
        unless @xml.elements['//DoseAdmin'] == nil
          @n3 = @n3 + various_forms_type_rdf(various_forms_type(@xml.elements['//DoseAdmin']), subj)
        end
        unless @xml.elements['//OtherRelatedMatters'] == nil
          @n3 = @n3 + various_forms_type_rdf(various_forms_type(@xml.elements['//OtherRelatedMatters']), subj)
        end
      end
      @n3
    end

  end

  class InfoPrecautionsDosage < RDF

    def initialize(xml, pino, section = 'PI_7') 
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//InfoPrecautionsDosage'] == nil
        @n3 << triple(subj, 'a', "pio:#{section}")
        case @xml.elements['//InfoPrecautionsDosage'].attributes["wordingPatternOfInfoPrecautionsDosage"]
        when '1'
          @n3 << triple(subj, 'dct:title', '"用法及び用量に関連する注意"@ja')
        when '2'
          @n3 << triple(subj, 'dct:title', '"用法用量に関連する注意"@ja')
        when '3'
          @n3 << triple(subj, 'dct:title', '"用法・用量に関連する注意"@ja')
        else
        end
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//InfoPrecautionsDosage']), subj)
      end
      @n3
    end

  end

  class ImportantPrecautions < RDF

    include PI
    def initialize(xml, pino, section = 'PI_8')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//ImportantPrecautions'] == nil
        @n3 = various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//ImportantPrecautions']), subj)
      end
      @n3
    end

  end


  class UseInSpecificPopulations < RDF

    include PI

    def initialize(xml, pino, section = 'PI_9')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    Sections = {
                 '9_1'=>'//UseInPatientsWithComplicationsOrHistoryOfDiseasesEtc',
                 '9_2'=>'//PatientsWithRenalImpairment',
                 '9_3'=>'//PatientsWithHepaticImpairment',
                 '9_4'=>'//MalesAndFemalesOfReproductivePotential',
                 '9_5'=>'//UseInPregnant',
                 '9_6'=>'//UseInNursing',
                 '9_7'=>'//PediatricUse',
                 '9_8'=>'//UseInTheElderly'
               }.freeze

    def rdf
      Sections.each do |sid, tag|
        unless @xml.elements[tag] == nil
          @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements[tag]), "pi:PI_#{sid}")
        end
      end
      @n3
    end

  end


  class Interaction < RDF

    def initialize(xml, pino, section = 'PI_10')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      summary_of_combination
      contra_indicated_combinations_rdf(contra_indicated_combinations)
      precautions_for_combinations_rdf(precautions_for_combinations)
      @n3
    end

    def summary_of_combination
      ary = []
      unless @xml.elements['//SummaryOfCombination'] == nil
        @xml.elements['//SummaryOfCombination/Item'].each_element do |e|
          ary << item(e)
        end
      end
      ary
    end

    def contra_indicated_combinations
      ary = []
      unless @xml.elements['//ContraIndicatedCombinations'] == nil
        @xml.elements['//ContraIndicatedCombinations'].each_element do |e|
          ary << contra_indicated_combination(e)
        end
      end
      ary
    end

    def contra_indicated_combinations_rdf(ary)
      subj = "pi:PI_10_1"
      @n3 << triple(subj, "a", "pio:PI_10_1")
      ary.each do |e|
        e[:contra_indication][:drug].each.with_index(1) do |drug, i|
          drug.to_a.each do |k, v|
            case k
            when :drug_name
              if v.key?(:simple_list)
                @n3 << triple("#{subj}", "pio:drug", "#{subj}.item#{i}")
                @n3 << triple("#{subj}.item#{i}", "a", "pio:ContraIndication")
                v[:simple_list][0].each do |drug_name|
                  if drug_name[:detail][0][0].key?(:attr) && drug_name[:detail][0][0][:attr].key?("ref")
                  elsif drug_name[:detail][0][0].key?(:text)
                    @n3 << triple("#{subj}.item#{i}", "pio:drug_name", "\"#{drug_name[:detail][0][0][:text]}\"@ja")
                  end
                end
              end
            when :clin_symptoms_and_measures
              if v.key?(:detail)
                @n3 << triple("#{subj}.item#{i}", "pio:clin_symptoms_and_measures", "\"#{v[:detail][0][0][:text]}\"@ja")
              end
            when :mechanism_and_risk_factors
              if v.key?(:detail)
                @n3 << triple("#{subj}.item#{i}", "pio:mechanism_and_risk_factors", "\"#{v[:detail][0][0][:text]}\"@ja")
              end
            else
            end
          end
        end
      end

      @n3
    end

    def precautions_for_combinations
      ary = []
      unless @xml.elements['//PrecautionsForCombinations'] == nil
        @xml.elements['//PrecautionsForCombinations'].each_element do |e|
          ary << precautions_for_combination(e)
        end
      end
      ary
    end

    def precautions_for_combinations_rdf(ary)
      subj = "pi:PI_10_2"
      @n3 << triple(subj, "a", "pio:PI_10_2")
      ary.each do |e|
        e[:precautions_for_combi][:drug].each.with_index(1) do |drug, i|
          drug.to_a.each do |k, v|
            case k
            when :drug_name
              if v.key?(:simple_list)
                @n3 << triple("#{subj}", "pio:drug", "#{subj}.item#{i}")
                @n3 << triple("#{subj}.item#{i}", "a", "pio:PrecautionsForCombi")
                v[:simple_list][0].each do |drug_name|
                  if drug_name[:detail][0][0].key?(:attr) && drug_name[:detail][0][0][:attr].key?("ref")
                  elsif drug_name[:detail][0][0].key?(:text)
                    @n3 << triple("#{subj}.item#{i}", "pio:drug_name", "\"#{drug_name[:detail][0][0][:text]}\"@ja")
                  end
                end
              end
            when :clin_symptoms_and_measures
              if v.key?(:detail)
                @n3 << triple("#{subj}.item#{i}", "pio:clin_symptoms_and_measures", "\"#{v[:detail][0][0][:text]}\"@ja")
              end
            when :mechanism_and_risk_factors
              if v.key?(:detail)
                @n3 << triple("#{subj}.item#{i}", "pio:mechanism_and_risk_factors", "\"#{v[:detail][0][0][:text]}\"@ja")
              end
            else
            end
          end
        end
      end
      @n3
    end

    def contra_indicated_combination(e)
      h = {}
      e.each_element do |elm|
        case elm.name
        when "Instructions"
#         h[:instructions] = instruction(elm)
        when "ContraIndication"
          h[:contra_indication] = contra_indication(elm)
        when "ExplanatoryNotesForContraIndication"
#         h[:explanatory_notes_for_contra_indication] = explanatory_notes_for_contra_indication(elm)
        end
      end
      h
    end


    def precautions_for_combination(e)
      h = {}
      e.each_element do |elm|
        case elm.name
        when "Instructions"
#          h[:instructions] = instruction(elm)
        when "PrecautionsForCombi"
          h[:precautions_for_combi] = precautions_for_combi(elm)
        when "ExplanatoryNotesForPrecautions"
#          h[:explanatory_notes_for_contra_indication] = explanatory_notes_for_contra_indication(elm)
        end
      end
      h 
    end

    def instruction(e)

    end

    def contra_indication(e)
      h = {:drug=>[]}
      e.each_element do |elm|
        case elm.name
        when "WidthDefinition"
#          h[:width_definition] = width_definition(elm)
        when "Drug"
          h[:drug] << drug(elm)
        end
      end
      h
    end

    def explanatory_notes_for_contra_indication(e)

    end

    def precautions_for_combi(e)
      h = {:drug=>[]}
      e.each_element do |elm|
        case elm.name
        when "WidthDefinition"
#          h[:width_definition] = width_definition(elm)
        when "Drug"
          h[:drug] << drug(elm)
        end
      end
      h
    end

    def width_definition(e)

    end

    def drug(e)
      drug = {}
      e.each_element do |elm|
        case elm.name
        when "DrugName"
          drug[:drug_name] = drug_name(elm)
        when "ClinSymptomsAndMeasures"
          drug[:clin_symptoms_and_measures] = clin_symptoms_and_measures(elm)
        when "MechanismAndRiskFactors"
          drug[:mechanism_and_risk_factors] = mechanism_and_risk_factors(elm)
        end
      end
      drug
    end

    def drug_name(e)
      various_forms_type(e)
    end

    def clin_symptoms_and_measures(e)
      various_forms_type(e)
    end

    def mechanism_and_risk_factors(e)
      various_forms_type(e)
    end
  end


  class AdverseEvents < RDF

    include PI

    def initialize(xml, pino, section = 'PI_11')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      common_precautions_for_adverse_rdf(common_precautions_for_adverse)
      serious_adverse_events
#      other_adverse_events
      other_adverse_events_rdf(other_adverse_events)
#      common_explanatory_notes_for_adverse
      @n3
    end

    def common_precautions_for_adverse()
      unless @xml.elements['//CommonPrecautionsForAdverse'] == nil
        cdata_content_type(@xml.elements['//CommonPrecautionsForAdverse'])
      end
    end

    def common_precautions_for_adverse_rdf(e)
      e.each do |elm| 
        @n3 << triple(subj, "pio:common_precautions_for_adverse", "\"#{elm[:lang][:text]}\"")
      end
    end

    def serious_adverse_events()
      unless @xml.elements['//SeriousAdverseEvents'] == nil
        unless @xml.elements['//SeriousAdverseEvents/Instructions'] == nil
          instructions(@xml.elements['//SeriousAdverseEvents/Instructions'])
        end
        unless @xml.elements['//SeriousAdverse'] == nil
          serious_adverse(@xml.elements['//SeriousAdverse'])
        end
        unless @xml.elements['//ExplanatoryNotesForSeriousAdverse'] == nil
          explanatory_notes_for_serious_adverse(@xml.elements['//ExplanatoryNotesForSeriousAdverse'])
        end
      end
    end

    def other_adverse_events()
      a = []
      unless @xml.elements['//OtherAdverseEvents'] == nil
        @xml.elements['//OtherAdverseEvents'].each_element do |elm|
          a << other_adverse_event(elm)
        end
      end
      a
    end

    def other_adverse_events_rdf(a)
      subj = "pi:PI_11_2"
      @n3 << triple(subj, "a", "pio:PI_11_2")
      a.each.with_index(1) do |h, i|
        s = "#{subj}.item#{i}"
        @n3 << triple(subj, "pio:section", s)
        if h.key?(:instructions)
          @n3 << triple(s, "pio:instructions", "\"#{h[:instructions]}\"")
        end
        h[:other_adverse].each.with_index(1) do |other_adverse_event, i|
          @n3 << triple(s, "pio:other_adverse_event", "#{s}.item#{i}")
          @n3 << triple("#{s}.item#{i}", "a", "pio:AdverseEvent")
          @n3 << triple("#{s}.item#{i}", "pio:adverse_reaction", "\"#{other_adverse_event[:adverse_reaction]}\"")
          @n3 << triple("#{s}.item#{i}", "pio:category", "\"#{other_adverse_event[:category]}\"")
          @n3 << triple("#{s}.item#{i}", "pio:frequency", "\"#{other_adverse_event[:frequency]}\"")
        end
        if h.key?(:explanatory_notes_for_other_adverse)
          @n3 << triple(s, "pio:explanatory_notes_for_other_adverse", "\"#{h[:explanatory_notes_for_other_adverse]}\"")
        end
      end
    end
    
    def common_explanatory_notes_for_adverse(e)
      cdata_content_type(e)
    end

    def instructions(e)
      various_forms_type(e)[:simple_list][0][0][:header][0][0][:lang][:text]
    end

    def serious_adverse(e)
      @n3 = @n3 + various_forms_type_rdf(various_forms_type(e), "pi:PI_11_1")
    end

    def explanatory_notes_for_serious_adverse(e)
      cdata_content_type(e)
    end

    def other_adverse_event(e)
      h = {}
      unless e.elements['Instructions'] == nil
        h[:instructions] = instructions(e.elements['Instructions'])
      end
      unless e.elements['OtherAdverse'] == nil
        h[:other_adverse] = other_adverse(e.elements['OtherAdverse'])
      end
      unless e.elements['ExplanatoryNotesForOtherAdverse'] == nil
        h[:explanatory_notes_for_other_adverse] = explanatory_notes_for_other_adverse(e.elements['ExplanatoryNotesForOtherAdverse'])
      end
      h
    end

    def other_adverse(e)
      a = []
      category_hash  = category_definition(@xml.elements['//OtherAdverse/CategoryDefinition'])
      frequency_hash = frequency_definition(@xml.elements['//OtherAdverse/FrequencyDefinition'])
      adverse_reactions_hash = adverse_reactions(@xml.elements['//OtherAdverse/AdverseReactions'])
      adverse_reactions_hash.to_a.each do |elm|
        h = {}
        h[:adverse_reaction] = elm[:detail][0][0][:text]
        h[:category] = category_hash[elm[:category_ref]]
        h[:frequency] = frequency_hash[elm[:frequency_ref]]
        a << h
      end
      a
    end

    def explanatory_notes_for_other_adverse(e)
      cdata_content_type(e)[0][:lang][:text]
    end


    def category_definition(e)
      h = {}
      e.each_element do |elm|
        ctgry = category(elm)
        h[ctgry[:id]] = ctgry[:detail][0][0][:text]
      end
      h
    end

    def category(e)
      various_forms_with_id_required_type(e)
    end

    def frequency_definition(e)
      h = {}
      e.each_element do |elm|
        freq = frequency(elm)
        h[freq[:id]] = freq[:detail][0][0][:text]
      end
      h
    end

    def frequency(e)
      various_forms_with_id_required_type(e)
    end

    def adverse_reactions(e)
      a = []
      e.each_element do |elm|
        h = adverse_reaction_description(elm)
        h[:category_ref] = elm.attribute(:categoryRef).to_s.split("id")[0]
        h[:frequency_ref] = elm.attribute(:frequencyRef).to_s.split("id")[0]
        a << h
      end
      a
    end

    def adverse_reaction_description(e)
      various_forms_type(e)
    end
  end

  class InfluenceOnLaboratoryValues < RDF

    include PI

    def initialize(xml, pino, section = 'PI_12')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//InfluenceOnLaboratoryValues'] == nil
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//InfluenceOnLaboratoryValues']), subj)
      end
      @n3
    end

  end

  class OverDosage < RDF

    include PI

    def initialize(xml, pino, section = 'PI_13')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//OverDosage'] == nil
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//OverDosage']), subj)
      end
      @n3
    end

  end


  class PrecautionsForApplication < RDF

    def initialize(xml, pino, section = 'PI_14')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//PrecautionsForApplication/OtherInformation'] == nil
        @n3 = @n3 + other_information_rdf(other_information(@xml.elements['//PrecautionsForApplication/OtherInformation']), subj, 0)
      end
      @n3
    end

  end


  class OtherPrecautions < RDF

    def initialize(xml, pino, section = 'PI_15')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//OtherPrecautions'] == nil
        unless @xml.elements['//InformationBasedOnClinicalUse'] == nil
          @n3 = @n3 + information_based_on_clinical_use #InformationBasedOnClinicalUse
        end
        unless @xml.elements['//InformationBasedOnNonclinicalStudies'] == nil
          @n3 = @n3 + information_based_on_nonclinical_studies #InformationBasedOnNonclinicalStudies
        end
#        other_information_rdf(other_information(@xml.elements['//OtherInformation']), subj, 0) #OtherInformation
      end
      @n3
    end

    def information_based_on_clinical_use
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//InformationBasedOnClinicalUse']), "pi:PI_15_1")
    end

    def information_based_on_nonclinical_studies
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//InformationBasedOnNonclinicalStudies']), "pi:PI_15_2")
    end 

  end


  class Pharmacokinetics < RDF

    include PI

    def initialize(xml, pino, section = 'PI_16')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    Sections = {
                 '16_1'=>'//BloodLevel',
                 '16_2'=>'//Absorption',
                 '16_3'=>'//Distribution',
                 '16_4'=>'//Metabolism',
                 '16_5'=>'//Excretion',
                 '16_6'=>'//SpecificPopulation',
                 '16_7'=>'//DrugAndDrugInteractions',
                 '16_8'=>'//PharmacokineticsEtc'
               }.freeze

    def rdf
      Sections.each do |sid, tag|
        unless @xml.elements[tag] == nil
          @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements[tag]), "pi:PI_#{sid}")
        end
      end
      @n3
    end

  end


  class ResultsOfClinicalTrials < RDF

   include PI

    def initialize(xml, pino, section = 'PI_17')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//ResultsOfClinicalTrials'] == nil
        unless @xml.elements['//EfficacyAndSafety'] == nil
          @n3 = @n3 + efficacy_and_safety(@xml.elements['//EfficacyAndSafety'])
        end
        unless @xml.elements['//PostMarketingSurveylancesEtc'] == nil
          @n3 = @n3 + post_marketing_surveylances_etc(@xml.elements['//PostMarketingSurveylancesEtc'])
        end
        unless @xml.elements['//ResultsOfClinicalTrialsEtc'] == nil
          @n3 = @n3 + results_of_clinical_trials_etc(@xml.elements['//ResultsOfClinicalTrialsEtc'])
        end
      end
      @n3
    end

    def efficacy_and_safety(e)
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(e), "pi:PI_17_1")
    end

    def post_marketing_surveylances_etc(e)
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(e), "pi:PI_17_2")
    end

    def results_of_clinical_trials_etc(e)
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(e), "pi:PI_17_3")
    end
  end

  class EfficacyPharmacology < RDF

    include PI

    def initialize(xml, pino, section = 'PI_18')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//EfficacyPharmacology'] == nil
        @n3 << triple(subj, "a", "pio:#{section}")

        i = 0
        @xml.elements['//EfficacyPharmacology'].each_element do |elm|
          m = elm.name.to_snake.to_sym
          case m
          when :mechanism_of_action
            @n3 = @n3 + mechanism_of_action(elm)
          when :measurement_method
            i += 1
            @n3 = @n3 + measurement_method(elm)
          when :other_information
            @n3 = @n3 + other_information_rdf(other_information(elm), subj, i)
            i += 1
          else
          end
        end
      end
      @n3
    end

    def mechanism_of_action(e)
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(e), "pi:PI_18_1")
    end

    def measurement_method(e, i)
      various_forms_wo_id_type_rdf(various_forms_wo_id_type(e), "#{subj}.item#{i}")
    end

  end

  class PhyschemOfActIngredients < RDF

    include PI

    def initialize(xml, pino, section = 'PI_19')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//PhyschemOfActIngredients'] == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        unless @xml.elements['//PhyschemOfActIngredientsSection'] == nil
          @n3 = @n3 + physchem_of_act_ingredients_section(@xml.elements['//PhyschemOfActIngredientsSection'])
        end
      end
      @n3
    end

    def physchem_of_act_ingredients_section(e)
      n3 = []
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        case m
        when :general_name      , :chemical_name, :molecular_formula,
             :molecular_weight  , :description_of_active_ingredients,
#             :structural_formula, :melting_point, :partition_coefficient,
             :melting_point, :partition_coefficient,
             :nature            , :nucleophysical_properties
          n3 << triple(subj, "pio:#{m}", "\"#{various_forms_type(elm)[:detail][0][0][:text]}\"")
        when :physchem_of_act_ingredients_section_title
          n3 << triple(subj, "pio:#{m}", "\"#{cdata_content_type(elm)[0][:lang][:text]}\"")
        else
        end
      end
      n3
    end
  end

  class PrecautionsForHandling < RDF

    include PI

    def initialize(xml, pino, section = 'PI_20')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//PrecautionsForHandling'] == nil
        @n3 << triple(subj, "a", "pio:#{section}")
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//PrecautionsForHandling']), subj)
      end
      @n3
    end
  end

  class ConditionsOfApproval < RDF

    include PI
    def initialize(xml, pino, section = 'PI_21')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//ConditionsOfApproval'] == nil
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//ConditionsOfApproval']), subj)
      end
      @n3
    end

  end

  class Package < RDF

    include PI
    def initialize(xml, pino, section = 'PI_22')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//Package'] == nil
        @n3 = @n3 + various_forms_wo_id_type_rdf(various_forms_wo_id_type(@xml.elements['//Package']), subj)
      end
      @n3
    end

  end

  class MainLiterature < RDF

    include PI
    def initialize(xml, pino, section = 'PI_23')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      i = 0
      unless @xml.elements['//MainLiterature'] == nil
        @xml.elements['//MainLiterature'].each_element do |e|
          i += 1
          @n3 << triple(subj, "dct:references", "#{subj}.item#{i}")
          @n3 << triple("#{subj}.item#{i}", "a", "bibo:Document")
          @n3 << triple("#{subj}.item#{i}", "rdfs:label", "\"#{reference(e)}\"")
          @n3 << triple("#{subj}.item#{i}", "pio:id", "\"#{e.attributes["id"]}\"")
        end
      end
      @n3
    end

    def reference(e)
      cdata_content_type(e)[0][:lang][:text]
    end
  end

  class AddresseeOfLiteratureRequest < RDF

    include PI
    def initialize(xml, pino, section = 'PI_24')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//AddresseeOfLiteratureRequest'] == nil
        @n3 << triple(subj, "pio:id", "\"#{@xml.elements['//AddresseeOfLiteratureRequest'].attributes["id"]}\"@ja")
        i = 0
        @xml.elements['//AddresseeOfLiteratureRequest'].each_element do |e|
          i += 1
          @n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
          unless e.elements['AddresseeOfInquiry'] == nil
            addressee_of_inquiry = cdata_content_type(e.elements['AddresseeOfInquiry'])[0][:lang][:text]
            @n3 << triple("#{subj}.item#{i}", "pio:addressee_of_inquiry", "\"#{addressee_of_inquiry}\"@ja")
          end
          unless e.elements['Address'] == nil
            address = cdata_content_type(e.elements['Address'])[0][:lang][:text]
            @n3 << triple("#{subj}.item#{i}", "pio:address", "\"#{address}\"@ja")
          end
          unless e.elements['ContactInformation'] == nil
#            contact_information = various_forms_type(e.elements['ContactInformation'])[:detail][0][0][:text]
            contact_information = various_forms_type(e.elements['ContactInformation'])
            if contact_information.key?(:detail)
              contact_info = contact_information[:detail][0][0][:text]
              @n3 << triple("#{subj}.item#{i}", "pio:contact_information", "\"#{contact_info}\"@ja")
            elsif contact_information.key?(:graphic)
              @n3 << triple("#{subj}.item#{i}", "pio:contact_information", "\"#{contact_information[:graphic][0][0]["gfname"]}\"")
            else
            end
          end
        end
      end
      @n3
    end

    def addressee_info(e)
      h = {}
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        h[m] = send(m, elm)
      end
      h
    end

    def addressee_of_inquiry(e)
      cdata_content_type(e)
    end

    def address(e)
      cdata_content_type(e)
    end

    def contact_information(e)
      various_forms_type(e)
    end

  end

  class AttentionOfInsurance < RDF

    include PI
    def initialize(xml, pino, section = 'PI_25')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      unless @xml.elements['//AttentionOfInsurance'] == nil
        @n3 << triple(subj, "pio:id", "\"#{@xml.elements['//AttentionOfInsurance'].attributes["id"]}\"")
        @n3 = @n3 + content_of_attention_of_insurance(@xml.elements['//ContentOfAttentionOfInsurance'])
      end
      @n3
    end

    def content_of_attention_of_insurance(e)
      various_forms_type_rdf(various_forms_type(e), subj)
    end

  end

  class NameAddressManufact < RDF

    include PI
    def initialize(xml, pino, section = 'PI_26')
      @xml = xml
      @pino = pino
      @n3 = []
      @section = section
      @subj = "pi:#{section}"
    end
    attr_accessor :xml, :pino, :n3, :section, :subj

    def rdf
      i = 0
      unless @xml.elements['//NameAddressManufact'] == nil
        @n3 << triple(subj, "pio:id", "\"#{@xml.elements['//NameAddressManufact'].attributes["id"]}\"")
        @xml.elements['//NameAddressManufact'].each_element do |elm|
          i += 1
          @n3 << triple(subj, "pio:section", "#{subj}.item#{i}")
          @n3 = @n3 + manufacturer_rdf(manufacturer(elm), "#{subj}.item#{i}")
        end
      end
      @n3
    end

    def manufacturer(e)
      h = {}
      e.each_element do |elm|
        m = elm.name.to_snake.to_sym
        h[m] = send(m, elm)
      end
      h
    end

    def manufacturer_rdf(e, subj)
      n3 = []
      e.each do |k, v|
        n3 << triple(subj, "pio:#{k}", "\"#{v[0][:lang][:text]}\"@ja")
      end
      n3
    end

    def type_of_industry(e)
      cdata_content_type(e)
    end

    def name(e)
      cdata_content_type(e)
    end

    def address(e)
      cdata_content_type(e)
    end

  end


end


class String
  def to_snake()
    self
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end
end

def help
  print "Usage: rdf_converter_pi_xml.rb [options] <file>\n"
  print "  -h, --help print help\n"
end

params = ARGV.getopts('h', 'help')

if params["help"] || params["h"]
  help
  exit
end

$prefixes = true if params["prefixes"]
$prefixes = true if params["p"]
pi = PI::RDF.new(ARGV.shift)
pi.rdf

