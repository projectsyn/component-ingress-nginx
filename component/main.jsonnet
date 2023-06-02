// main template for ingress-nginx
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local prometheus = import 'lib/prometheus.libsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.ingress_nginx;

local psaLabel(mode, level) =
  local enabled = params.pod_security_admission.enabled && level != null && level != '';
  if !enabled then {}
  else if !std.member([ 'privileged', 'baseline', 'restricted' ], level) then error 'Unknown Pod Security Standard: "%s"' % level
  else
    {
      ['pod-security.kubernetes.io/%s' % mode]: level,
    };

local namespace = (
  if std.member(inv.applications, 'prometheus') then
    prometheus.RegisterNamespace(kube.Namespace(params.namespace))
  else
    kube.Namespace(params.namespace)
) + {
  metadata+: {
    labels+:
      psaLabel('audit', params.pod_security_admission.audit) +
      psaLabel('warn', params.pod_security_admission.warn) +
      psaLabel('enforce', params.pod_security_admission.enforce),
  },
};

// Define outputs below
{
  '00_namespace': namespace,
}
