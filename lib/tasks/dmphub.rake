# One off tasks for pushing histroical plans to the DMPHub
namespace :dmphub do

  desc "Gather all NSF templates and push them to the DMPHub"
  task nsf: :environment do
    org = Org.where('orgs.name LIKE ? OR orgs.name LIKE ?', '%NSF%', '%NASA%').first
    return 'No NSF org found!' unless org.present?

    template_ids = Template.where(org_id: org.id)
    return 'No NSF templates found!' unless template_ids.any?

    hub = Dmphub::RegistrationService.new

    #.where('(LENGTH(plans.title) - LENGTH(REPLACE(plans.title, \' \', \'\')) + 1) > 5')

    Plan.where(template_id: template_ids, doi: nil)
        .where.not(visibility: 2).each do |plan|
      next if plan.title.downcase.include?('test')

      # The partial we are rending uses a URL helper but Rake doesn't have
      # access to that so we need to just manually add the URL
      json = ActionController::Base.new.render_to_string partial: '/plans/rda_common_standard',
        locals: { plan: plan, plan_url: Proc.new { |obj| obj.id } }
      json = JSON.parse(json)
      json['dmp']['dmp_ids'] = [{
        'category': 'url',
        'value': "https://dmptool.org/plans/#{plan.id}"
      }]

      begin
        p "Registering Plan #{plan.id} - #{plan.title}"
        doi = hub.register(dmp: json.to_json)
        p "    got DOI: #{doi}"
        plan.update(doi: doi)

      rescue StandardError => se
        p se.message
        next
      end
    end
  end

end
