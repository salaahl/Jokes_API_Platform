<?php

namespace App\Controller\Nutriverif;

use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class NutriverifController extends AbstractController
{
    private HttpClientInterface $httpClient;
    private LoggerInterface $logger;

    public function __construct(HttpClientInterface $httpClient, LoggerInterface $logger)
    {
        $this->httpClient = $httpClient;
        $this->logger = $logger;
    }

    #[Route('/search-products', name: 'search_products', methods: ['POST'])]
    public function search(Request $request): JsonResponse
    {
        try {
            $data = $request->toArray();
            $url = $data['url'] ?? null;
            $method = strtoupper($data['method'] ?? 'GET');
            $incomingBody = $data['body'] ?? '';

            if (!isset($url)) {
                $this->logger->warning('NutriVerif: Tentative d\'appel sans paramètre "url".');
                return $this->json(
                    ['error' => 'Le paramètre "url" est requis.'],
                    Response::HTTP_BAD_REQUEST
                );
            }

            $payloadParams = [];
            parse_str($incomingBody, $payloadParams);

            $options = [
                'headers' => [
                    'User-Agent' => 'NutriVérif/1.0 (sokhona.salaha@gmail.com)',
                ],
            ];

            if ('POST' === $method && !empty($payloadParams)) {
                if (str_contains($url, 'search.openfoodfacts.org')) {
                    $options['json'] = $payloadParams; // JSON pour Search-a-licious
                } else {
                    $options['body'] = $payloadParams; // form-urlencoded pour cgi/search.pl
                }
            } elseif ('GET' === $method && !empty($payloadParams)) {
                $options['query'] = $payloadParams;
            }

            $response = $this->httpClient->request($method, $url, $options);

            $statusCode = $response->getStatusCode();

            if (200 !== $statusCode) {
                $this->logger->error(
                    "NutriVerif: OpenFoodFacts a renvoyé un code $statusCode pour l'URL : $url"
                );

                return $this->json(
                    ['error' => 'Erreur lors de l\'appel à OpenFoodFacts.', 'status' => $statusCode],
                    Response::HTTP_BAD_GATEWAY
                );
            }

            $content = $response->getContent();
            $decoded = json_decode($content, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->logger->error('NutriVerif: Réponse non-JSON', [
                    'preview' => substr($content, 0, 300)
                ]);
                return $this->json(
                    ['error' => 'Réponse non-JSON reçue.'],
                    Response::HTTP_BAD_GATEWAY
                );
            }

            return $this->json($decoded);
        } catch (\Exception $e) {
            $this->logger->critical('NutriVerif: Crash ! Message : ' . $e->getMessage(), [
                'exception' => $e
            ]);

            return $this->json(
                ['error' => 'Une erreur interne est survenue.', 'details' => $e->getMessage()],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
