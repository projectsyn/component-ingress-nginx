local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.ingress_nginx;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('ingress-nginx', params.namespace);

{
  'ingress-nginx': app,
}
