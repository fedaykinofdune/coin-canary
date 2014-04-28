task 'multipool:worker:supervisor' => :environment do
  Multipool::Worker.supervisor
end
